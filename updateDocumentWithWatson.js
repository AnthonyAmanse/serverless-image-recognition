var Cloudant = require('@cloudant/cloudant');
var fs = require('fs');
var cloudant;
var dbName;

function main(params) {
    cloudant = Cloudant({account:params.USERNAME, password:params.PASSWORD});
    dbName = params.DBNAME;
    return new Promise(function(resolve, reject) {
        let mydb = cloudant.db.use(dbName);
        mydb.attachment.get(params.id, 'image', function(err, data) {
            if (err) {
                reject(err);
            } else {
                console.log(params)
                resolve(processImageToWatson(data,params.id,params.WATSON_VR_APIKEY));
                // if (typeof data._attachments == "undefined") {
                //     console.log("Attachment isn't existing");
                //     reject({"reason":"Attachment isn't existing"});
                // } else {
                //     data.WATSON_VR_APIKEY = params.WATSON_VR_APIKEY
                //     resolve(data);
                // }
            }
        });
    });
}

function processImageToWatson(data,id,apikey) {
    let filename = __dirname + '/' + id;
    fs.writeFileSync(filename, data)
    let VisualRecognitionV3 = require('watson-developer-cloud/visual-recognition/v3');
    var visualRecognition = new VisualRecognitionV3({
        version: '2018-03-19',
        iam_apikey: apikey,
    });

    var watsonvrparams = {
        images_file: fs.createReadStream(filename)
    };
    return new Promise(function(resolve, reject) {
        visualRecognition.classify(watsonvrparams, function(err, res) {
            if (err) {
                console.log(err);
                reject(err);
            } else {
                resolve(updateDocument(res,id));
            }
        });
    });
}

function updateDocument(watsonResult,id) {
    return new Promise(function(resolve, reject) {
        let mydb = cloudant.db.use(dbName);
        mydb.get(id, function (err,doc) {
            if (err) {
                reject(err);
            } else {
                doc.watsonResults = watsonResult.images[0].classifiers;
                mydb.insert(doc, function(err,body) {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(body);
                    }
                });
            }
        });
    });
}
