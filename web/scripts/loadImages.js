function getAllImageDocuments() {
  $.ajax({
      url: testCloudantURL + imageDatabase + "/_all_docs",
      type: "GET",
      headers: {
        "Authorization": "Basic " + btoa(username + ":" + password)
      },
      success: function (data) {
        for (var id in data.rows) {
          getImage(data.rows[id].id)
        }
      },
      error: function (jqXHR, textStatus, errorThrown) {
        console.log(errorThrown);
        console.log(textStatus);
        console.log(jqXHR);
      }
  });
}

function getImage(id) {
  var image = new Image();

  var imageSection = document.createElement('div');
  var imageHolder = document.createElement('div');
  image.src = testCloudantURL + imageDatabase + "/" + id + "/image"
  image.className = "uploadedImage";
  imageSection.id = id
  imageSection.className = "imageSection";
  imageHolder.className = "imageHolder";
  imageHolder.appendChild(image);
  imageSection.appendChild(imageHolder);
  uploadedImages.prepend(imageSection);
  getDocumentWithId(id, imageSection, 0);
}


getAllImageDocuments();

// var localDB = new PouchDB('test');
// var remoteDB = new PouchDB("https://d1dda683-a71d-43ca-9c92-bf111700dc00-bluemix:fa2971ea3c351e710593bd1fb85d6b714dd5d2c9cdc03a49568f58fd8874cb1f@d1dda683-a71d-43ca-9c92-bf111700dc00-bluemix.cloudant.com/test");
// localDB.info().then(function (info) {
//   console.log(info);
// });
// remoteDB.info().then(function (info) {
//   console.log(info);
// });
// localDB.sync(remoteDB).on('change', function (change) {
//   // yo, something changed!
//   console.log("something changed")
//   console.log(change)
// }).on('complete', function () {
//   // yay, we're done!
//   console.log("done")
// }).on('error', function (err) {
//   // boo, something went wrong!
//
//   console.log("error");
//   console.log(err);
// });;
