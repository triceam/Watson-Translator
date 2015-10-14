/**
 * @license
 * Licensed Materials - Property of IBM
 * 5725-I43 (C) Copyright IBM Corp. 2014, 2015. All Rights Reserved.
 * US Government Users Restricted Rights - Use, duplication or
 * disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
 */

var express = require('express');
var passport = require('passport');
var ImfBackendStrategy = require('passport-imf-token-validation').ImfBackendStrategy;
var imf = require('imf-oauth-user-sdk');

var watson = require('watson-developer-cloud');

var translation_credentials, tts_credentials;

if (process.env.hasOwnProperty("VCAP_SERVICES")) {
    var env = JSON.parse(process.env.VCAP_SERVICES);
	translation_credentials = env['language_translation'][0].credentials;
    translation_credentials.version = "v2";
	
	tts_credentials = env['text_to_speech'][0].credentials;
    tts_credentials.version = "v1";
}
else {
	translation_credentials = {
		"url": "https://gateway.watsonplatform.net/language-translation/api",
		"username": "",
		"password": "",
        "version": 'v2'
	};
	
	tts_credentials = {
		url: 'https://stream.watsonplatform.net/text-to-speech/api',
		version: 'v1',
		username: '',
		password: '',
	}
}


var language_translation = watson.language_translation(translation_credentials);
var textToSpeech = watson.text_to_speech(tts_credentials);


var app = express();

//only use this on bluemix
if (process.env.hasOwnProperty("VCAP_SERVICES")) {
	passport.use(new ImfBackendStrategy());
	app.use(passport.initialize());
}


//redirect to mobile backend application doc page when accessing the root context
app.get('/', function(req, res){
	res.sendfile('public/index.html');
});

// create a public static content service
app.use("/public", express.static(__dirname + '/public'));

// create another static content service, and protect it with imf-backend-strategy
app.use("/protected", passport.authenticate('imf-backend-strategy', {session: false }));
app.use("/protected", express.static(__dirname + '/protected'));

// create a backend service endpoint
app.get('/publicServices/generateToken', function(req, res){
		// use imf-oauth-user-sdk to get the authorization header, which can be used to access the protected resource/endpoint by imf-backend-strategy
		imf.getAuthorizationHeader().then(function(token) {
			res.send(200, token);
		}, function(err) {
			console.log(err);
		});
	}
);

//create another backend service endpoint, and protect it with imf-backend-strategy
app.get('/protectedServices/test', passport.authenticate('imf-backend-strategy', {session: false }),
		function(req, res){
			res.send(200, "Successfully access to protected backend endpoint.");
		}
);


app.get('/translate', function(req, res){
   
	language_translation.translate(req.query, function(err, translation) {
        if (err) {
          console.log(err)
          res.send( err );
		} else {
          console.log(translation);
          res.send( translation );
        }
    });
});


app.get('/synthesize', function(req, res) {
  var transcript = textToSpeech.synthesize(req.query);
  transcript.on('response', function(response) {
    if (req.query.download) {
      response.headers['content-disposition'] = 'attachment; filename=transcript.flac';
    }
  });
  transcript.on('error', function(error) {
    console.log('Synthesize error: ', error)
  });
  transcript.pipe(res);
});

var port = (process.env.VCAP_APP_PORT || 3000);
app.listen(port);
console.log("mobile backend app is listening at " + port);
