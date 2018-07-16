# Serverless Image Recognition with Cloud Functions

The application demonstrates an IBM Cloud Functions (based on Apache OpenWhisk) that gets an image from the Cloudant database and classifies it through Watson Visual Recognition. The use case demonstrates how actions work with data services and execute logic in response to Cloudant events.

One function, or action, is triggered by changes (in this use case, an upload of a document) in a Cloudant database. These documents are piped to another action that submits the image to Watson Visual recognition and upload a new document in Cloudant with the classifiers produced by Watson.

When the reader has completed this Code Pattern, they will understand how to:

* Create and Deploy Cloud Functions
* Trigger Cloud Functions with Cloudant changes
* Use Watson Image Recognition with Cloud Functions

![](docs/architecture.png)

## Flow

1. User takes or chooses a picture from the gallery.
2. The image is stored in the Cloudant database.
3. Cloud Function is triggered when there's a new image in the database.
4. Cloud Function gets the image and uses Watson Visual Recognition to process the image.
5. Cloud Function stores the results (classes with scores) from Visual Recognition in the database.
6. The user can see the new tags or classes in the image they uploaded.

## Included components

* [IBM Cloud Functions](https://console.ng.bluemix.net/openwhisk) (powered by Apache OpenWhisk): Execute code on demand in a highly scalable, serverless environment.
* [Cloudant](https://console.ng.bluemix.net/catalog/services/cloudant-nosql-db): A fully managed data layer designed for modern web and mobile applications that leverages a flexible JSON schema.
* [Watson Visual Recognition](https://www.ibm.com/watson/developercloud/visual-recognition.html): Visual Recognition understands the contents of images - visual concepts tag the image, find human faces, approximate age and gender, and find similar images in a collection.

## Featured technologies

* [Serverless](https://www.ibm.com/cloud-computing/bluemix/openwhisk): An event-action platform that allows you to execute code in response to an event.

# Steps

1. [Clone the repo](#1-clone-the-repo)
2. [Create Watson services with IBM Cloud](#2-create-watson-services-with-ibm-cloud)
3. [Import the Conversation workspace](#3-import-the-conversation-workspace)
4. [Load the Discovery documents](#4-load-the-discovery-documents)
5. [Configure credentials](#5-configure-credentials)
5. [Run the application](#6-run-the-application)

### 1. Clone the repo

Clone the `serverless-image-recognition` locally. In a terminal, run:

```
$ git clone https://github.com/IBM/serverless-image-recognition
```

### 2. Create IBM Cloud Services

Create a [**Cloudant**](https://console.bluemix.net/catalog/services/cloudant) instance with IBM Cloud and name it `serverless-pattern`. Launch the Cloudant web console and create a database named `images` and `tags`.

Create a [Watson Visual Recognition](https://console.bluemix.net/catalog/services/visual-recognition) instance and name it `serverless-pattern-image-recognition`. Copy the API Key in the Credentials section and paste it in the `local.env` file in the value of `WATSON_VISUAL_APIKEY`

### 3. Create Cloud Functions

Make sure you have the right environment variables in the `local.env` file.

### 4. Launch Application

# Sample output

# Links

# License
[Apache 2.0](LICENSE)
