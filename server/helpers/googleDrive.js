var fs = require('fs');
var readline = require('readline');
var google = require('googleapis');
var googleAuth = require('google-auth-library');
//var folderName = "Projekt - Internetprogrammering";

// If modifying these scopes, delete your previously saved credentials
// at ~/.credentials/drive-nodejs-quickstart.json
var SCOPES = ['https://www.googleapis.com/auth/drive.readonly'];
var TOKEN_DIR = (process.env.HOME || process.env.HOMEPATH ||
    process.env.USERPROFILE) + '/.credentials/';
var TOKEN_PATH = TOKEN_DIR + 'interactiveCanvas.json';
var service = google.drive('v3');
var client_secret;

// Load client secrets from a local file.
fs.readFile('./helpers/client_secret.json', function processClientSecrets(err, content) {
  if (err) {
    console.log('Error loading client secret file: ' + err);
    return;
  }
  // Authorize a client with the loaded credentials, then call the
  // Drive API.
  client_secret = JSON.parse(content)
  console.log("client secret read "+ client_secret);
});


/**
 * Create an OAuth2 client with the given credentials, and then execute the
 * given callback function.
 *
 * @param {Object} credentials The authorization client credentials.
 * @param {function} callback The callback to call with the authorized client.
 */
exports.authorize = function(folder_id, callback) {
  if(client_secret){
    var clientSecret = client_secret.installed.client_secret;
    var clientId = client_secret.installed.client_id;
    var redirectUrl = client_secret.installed.redirect_uris[0];
    var auth = new googleAuth();
    var oauth2Client = new auth.OAuth2(clientId, clientSecret, redirectUrl);

    // Check if we have previously stored a token.
    fs.readFile(TOKEN_PATH, function(err, token) {
      if (err) {
        console.log("creates New token")
        getNewToken(oauth2Client, callback);
      } else {
        console.log("retrivees token")
        oauth2Client.credentials = JSON.parse(token);
        listFiles(folder_id, oauth2Client,callback);

      }
    });
  }else{
    callback(new Error("problem with clientSecret"))
    
  }
  }

/**
 * Get and store new token after prompting for user authorization, and then
 * execute the given callback with the authorized OAuth2 client.
 *
 * @param {google.auth.OAuth2} oauth2Client The OAuth2 client to get token for.
 * @param {getEventsCallback} callback The callback to call with the authorized
 *     client.
 */
function getNewToken(oauth2Client, callback) {
  var authUrl = oauth2Client.generateAuthUrl({
    access_type: 'offline',
    scope: SCOPES
  });
  console.log('Authorize this app by visiting this url: ', authUrl);
  var rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  rl.question('Enter the code from that page here: ', function(code) {
    rl.close();
    oauth2Client.getToken(code, function(err, token) {
      if (err) {
        console.log('Error while trying to retrieve access token', err);
        return;
      }
      oauth2Client.credentials = token;
      storeToken(token);
      callback(oauth2Client);
    });
  });
}

/**
 * Store token to disk be used in later program executions.
 *
 * @param {Object} token The token to store to disk.
 */
function storeToken(token) {
  try {
    fs.mkdirSync(TOKEN_DIR);
  } catch (err) {
    if (err.code != 'EEXIST') {
      throw err;
    }
  }
  fs.writeFile(TOKEN_PATH, JSON.stringify(token));
  console.log('Token stored to ' + TOKEN_PATH);
}

/**
 * Lists the names and IDs of up to 10 files.
 *
 * @param {google.auth.OAuth2} auth An authorized OAuth2 client.
 */

function listFiles(folder_id, auth, callback) {
  console.log(folder_id)
  // var id = getFolderID(folderName, auth, function(err, id) {
    var loadedFiles = [];
    service.files.list({
      auth: auth,
      q: "'"+folder_id+"' in parents",
      fields: "files(iconLink,id,name,thumbnailLink,webViewLink)" //files(name ,id ,iconLink,thumbnailLink ,webContentLink, webViewLink)"

    }, function(err, response) {
      if (err) {
        console.log('The API returned an error: ' + err);
        callback(err);
        return;
      }
      var files = response.files;
      if (files.length == 0) {
        callback(new Error('No files found'));
      } else {
        loadedFiles = files;       
      }
      callback(err,loadedFiles);
    });
  // });
}

function getFolderID(name, auth, callback){
  //var service = google.drive('v3
  console.log(name);
    service.files.list({
    auth: auth,
    q: "mimeType = 'application/vnd.google-apps.folder' and name = '" + name + "'",
    fields: "files(id)"

  }, function(err, response) {
    if (err) {
      console.log('The API returned an error: ' + err);
      return;
    }
    var folders = response.files;
    if (folders.length == 0) {
      console.log('No folder found.');
      callback(new Error('No folders found'));
    } else if (folders.length == 1) {
      console.log("found one folder")
      var file = folders[0];
      console.log('%s (%s)', file.name, file.id);
      callback("",file.id);
    } else {
      console.log("found more than one folder one folder")
      callback(new Error("Found more than one folder. Couldn't choose which you wanted"));
    }
  });
}
