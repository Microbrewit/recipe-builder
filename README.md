Microbrew.it Recipe Builder
====================

This repository contains the recipe builder used on Microbrew.it.

## The Application
The recipe builder is an Angluar.js-application that communicates directly with the API-server.

## Installation
You need Node.js and NPM installed globally on your system.
In addition you need Ruby and the gem compass installed.

Open a terminal instance and navigate to the cloned microbrew-it.frontend directory and run the following commands:

- ```npm install -g bower grunt-cli```

- ```cp microbrew-it.json-dist microbrew-it.json```

- ```npm install``` (installs local npm dependencies, mostly grunt tasks)

- ```bower install``` (gets frontend dependencies like for isntance Angular)

- ```grunt``` (runs the build process, starts a node instance, and starts a watcher).

As one command:
- ```npm install -g bower grunt-cli && cp microbrew-it.json-dist microbrew-it.json && npm install && bower install && grunt```

When pulling a new update you may want to run this command in case there are new dependencies:
- ```npm install && bower install && grunt```

Microbrew.it should now build, and a node instance serving the frontend should be started at http://localhost:3000.
