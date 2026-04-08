[![Build Status](https://ci.wcnp2.<priv-dom>/buildStatus/icon?job=nextech%2FleveragedAI-genai-starter-kit%2Fmain)](https://ci.wcnp2.<priv-dom>/job/nextech/job/leveragedAI-genai-starter-kit/job/main/) [![Generic badge](https://img.shields.io/badge/Demo-Available-<COLOR>.svg)](http://leveragedai-genai-starter-kit.radial.dev.k8s.<priv-dom>/) [![Generic badge](https://img.shields.io/badge/API-Available-<COLOR>.svg)](http://leveragedai-genai-starter-kit.radial.dev.k8s.<priv-dom>/api/docs)

![GenAI QandA Example](https://gecgithub01.<priv-dom>/nextech/leveragedAI-genai-starter-kit/blob/main/app/assets/QA-screenshot.png?raw=true)

# LLM (Large Language Model) Starter Kit
Multiple demos featuring LLM capability.
- Summarization
- Zero Shot Classification with Label Seeding and Explainability
- Question Answering using vector search for context
- Document Translation
- FAQ Generation
- Natural Language SQL Queries


See branches for additional demos which may not have been integrated into the primary demo.

## Setup

### Prerequisites

#### LLM Model Credentials

##### Route A - Azure Sandbox

In order to use this repo, you need access to a GenAI model. The easiest way to do that is via a direct, Azure Cognitive Services model. Although it is planned to decommission, you may have the ability to request access to a Sandbox environment such as EBS's GenAI Sandbox: https://confluence.<priv-dom>/display/GA/Onboarding+to+Generative+AI+Sandboxes

Set `app/envs/nosecrets.env` environment variables to look as follows (without changing unlisted variables):

```
API_TYPE=azure
API_BASE=<YOUR_API_BASE_ENDPOINT>
API_VERSION=<YOUR_MODEL_VERSION>
DEPLOYMENT_NAME=<YOUR_GENERATIVE_MODEL>
EMBED_DEPLOYMENT_NAME=<YOUR_EMBED_MODEL>
```

Set `app/envs/secrets.env` to at least contain:

```
AZURE_OPENAI_KEY=<YOUR_API_KEY>

```

##### Route B - Element LLM Gateway

If you are targeting a production deployment, you should not use the above method. You should start by using the Element LLM Gateway. You must use ServiceMesh (currently; key-based access is planned) to do this access. This means generating your service mesh headers. To request access to the Element LLM Gateway, use this: https://dx.<priv-dom>/documents/product/Element%20GenAI%20Platform/Onboarding-to-LLM-Gateway-1648545176

Set `app/envs/nosecrets.env` environment variables to look as follows (without changing unlisted variables):

```
API_TYPE=azure
API_BASE=<YOUR_API_BASE_ENDPOINT>
API_VERSION=<YOUR_MODEL_VERSION>
DEPLOYMENT_NAME=<YOUR_GENERATIVE_MODEL>
EMBED_DEPLOYMENT_NAME=<YOUR_EMBED_MODEL>
```

Set `app/envs/secrets.env` to at least contain:

```

```

#### (optional) GCS Bucket

If you want to persist your embeddings in GCS, you should provision a GCS bucket (or use an existing one). 

To do this, you will need a Google Cloud Project. You'll need all the appropriate documentation to do this (SSP, EPRA, Model Review, APM Record). Once the project is created, you can create a bucket and use a service account to get its credentials. Place those in `secrets` and ensure the `GCS_CREDENTIALS_FILENAME` environment variable is set in the `app/envs/nosecrets.env` file.

#### Manual Credentials

If you already have credentials, you just need to pass them into the appropriate environment variable in `app/envs/secrets.env`. You will need to create this file. Moreover, if you plan to deploy, you'll need to ensure this file is accessible via Akeyless as configured in your `kitt.yml` file.

### Setup Wizard

To run the setup wizard to get a local dev environment configured automatically (the repo is, by default, configured for deployment) run:

```
./environment_setup.sh
```

### Manual
Follow instructions for installing anaconda [here](https://docs.anaconda.com/free/anaconda/install/) (for local test environments).

```
git clone https://gecgithub01.<priv-dom>/nextech/leveragedAI-genai-starter-kit
cd leveragedAI-genai-starter-kit
conda create -n genaisk python==3.9 --yes
conda activate genaisk
pip install -r requirements.txt
```

Adjust environment variables in app/envs/nosecrets.env to fit your needs.

### AKeyless Secrets (LeverageAI Group Only)

This application uses some secrets that you need to retrieve from akeyless. Download them from here:

https://akeyless.gw.prod.glb.us.<priv-dom>:18888/items?id=55420601&name=%2FProd%2FWCNP%2Fhomeoffice%2Fradial-devs%2Fleveragedai-genai-starter-kit%2FleveragedAI-genAI-starter-kit-azure-key

and move the data into a file: `/etc/secrets/leveragedAI-GenAI-Starter-Kit-Secrets.env` OR rename the file an place it in `app/envs/secrets.env`

The secrets file must contain at least `AZURE_OPENAI_KEY` set to your Azure OpenAI key. The Azure OpenAI key can be obtained from the Azure Sandbox url under https://oai.azure.com/portal/<YOUR_PROJECT_ID>/chat, then under `Chat session`, click `View code` and the key is at the bottom.

If you use the root location, it will be loaded from there automatically into the `app/envs/secrets.env` location. This emulates what akeyless with do in a real deployment for testing. If you do not provide the `/etc/secrets/leveragedAI-GenAI-Starter-Kit-Secrets.env`, the file at `app/envs/secrets.env` will be used automatically.

#### AKeyless Access (LeveragedAI Group Only)

To access the radial llm secrets, you need to submit a service now request for access to the AD group `radial-devs`. You can do that here (and follow the below inputs): https://<priv-dom>.service-now.com/wm_sp/?id=sc_cat_item_guide&sys_id=b3234c3b4fab8700e4cd49cf0310c7d7

![Service Now AD Request for Group](https://gecgithub01.<priv-dom>/nextech/leveragedAI-genai-starter-kit/blob/cold-start-dev-improvements/app/assets/ad-req-0.png?raw=true)

![Service Now AD Request for radial-devs](https://gecgithub01.<priv-dom>/nextech/leveragedAI-genai-starter-kit/blob/cold-start-dev-improvements/app/assets/ad-req-1.png?raw=true)

Note for first-time users of akeyless - make sure you log in via SAML:

![Service Now AD Request for radial-devs](https://gecgithub01.<priv-dom>/nextech/leveragedAI-genai-starter-kit/blob/cold-start-dev-improvements/app/assets/akeyless-saml.png?raw=true)

## Package Structure and Important Details

```
├── .streamlit            <- Streamlit global application configurations
│   ├── .config.toml      <- Global config for streamlit application
├── app                   <- Main application directory
│   ├── assets            <- Static assets such as images.
│   ├── envs              <- Environment files to be automatically loaded on start
│   │   ├── nosecrets.env <- Non-secret environment information
│   │   └── secrets.env   <- Secret environment information (loaded by akeyless on deploy)
│   ├── pages             <- The various pages in the application
│   ├── utils             <- Utility functions used application-wide
│   ├── api.py            <- The API interface definition (references the pages directly)
│   └── Home.py           <- The main home page/entry point for the streamlit app
├── mnt                   <- The mounted storage directory (auto-created if not present)
├── packages              <- Local package storage for specialized package installs
├── projects              <- Sample data projects
├── secrets               <- A stub folder into which secrets will be auto-populated by akeyless
├── startup_scripts       <- Scripts which may be launched at startup of the container
├── testing               <- New features/tests
├── .gitignore            <- Files to exclude (mainly secrets and local project config)
├── docker-compose.yaml   <- Used for local deploy of redis or other multi-image test setups (not used in deployment)
├── Dockerfile            <- Deployment container image
├── start_server.sh       <- Deployment container image entrypoint
├── environment_setup.sh  <- Helper script for configuring your environment on first-start (i.e. setting environment variables)
├── kitt.yml              <- Deployment definition
├── nginx.conf            <- Proxy configuration (for multi-port application exposure; i.e. UI+API)
├── proximity.pip.ini     <- Proximity package management definition (for pip install on WMT network)
├── README.md             <- This file
├── requirements.txt      <- The requirements file for reproducing the analysis environment
└── sr.yaml      <- The service registry configuration file
```

### Proxy Configuration

The local proxy is configured using `nginx.conf` and defines mappings from endpoint to port. Note that for FastAPI implementations, it is necessary to set `--root-path /<ENDPOINT>` in the uvicorn call per `create_api_endpoints.sh`. For streamlit and other websocket applications, it is necessary to include the associated headers as shown in the `nginx.conf`. No modifications are needed unless other port mappings are added.

### API vs. Front End

This application is both an API and a front end. The API is set to deploy at `/api` with docs at `/api/docs`. The front end is deployed at `/`. 

![API Example](https://gecgithub01.<priv-dom>/nextech/leveragedAI-genai-starter-kit/blob/main/app/assets/fastapi-screenshot.png?raw=true)

## Run Instructions

### Start Locally (See Dev Environment above)
```
./start_server.sh
```

### Start in Docker Locally (no Dev Environment needed)
Note: You may want to comment out the redis container if you're not using it. See the Redis Vector Store section for more info.

```
docker-compose up --build
```

### GCS Integration

GCS integration in deeplake can be performed directly using deeplake's interface. In this case, similarly to the fuse store, the credentials file needs to be loaded from akeyless (see `kitt.yml`) and stored in `secrets`

### Deployment Debugging

When debugging this package in deployment, the following 3 commands are very useful:

1. Connect to the Kubernetes cluster:

```
sledge connect uscentral1-dev-gke01
```

2. View the container logs:

```
kubectl logs $(kubectl get pods -n radial | grep leveragedai-genai-starter-kit | cut -d' ' -f1) -n radial
```

3. SSH into the container:

```
kubectl exec -it $(kubectl get pods -n radial | grep leveragedai-genai-starter-kit | cut -d' ' -f1) -n radial -- bash
```

4. Delete/restart the container (as in akeyless key update)

```
kubectl delete pod $(kubectl get pods -n radial | grep leveragedai-genai-starter-kit | cut -d' ' -f1) -n radial
```

### How to Contribute

1. Request membership to https://gecgithub01.<priv-dom>/orgs/nextech/teams/leveragedai-starter-kit-contributors/ . 
2. Make a branch for your addition(s)
3. Either pitch an idea to the maintainers (you can use email, teams, or Issues+tagging as you prefer) or select an item from the TODO below
4. Make a PR with your merged changes when you're ready

### TODO

## Evaluation and Test
* Test coverage for API/models
* Evaluation Metrics - Speed
* Evaluation Metrics - Answer Quality
* Evaluation Metrics - Citation Relevance
* Evaluation Metrics - Price
* Adversarial testing (i.e. "red team" style automated attacks that attempt to get the model to do things it shouldn't)

## Integration
* Integrate Milvus MSO
* Plugin integration (needs investigation)
* Integrate multiple vector store indicies simultaneously
* Fine-Tuning examples (needs investigation)

## API Features
* Additional API integrations - Vector Search
* Additional API integrations - Index Creation
* Additional API integrations - Extractive Model Call

## Major Features
* Support append, update, and overwrite modes for vector store loading
* Feedback integration examples for different use cases (we already have some of this, but showing how that feedback could be collected and used to tune the model would be great)
* Monitoring (especially around cost and feedback components) and rate limiting
* Content Management System for Vector Store
* Cache integration for API calls (see GPTCache)
* Add element api key based auth example
* Add open source model support
* Add Google model support
* Prompt engineering tool
* GenAI Metrics interrogator
* Parallel semantic search on QnA example (https://www.meilisearch.com/docs/learn/getting_started/quick_start?utm_campaign=oss&utm_source=github&utm_medium=meilisearch&utm_content=get-started maybe an option)

## Bug Fixes
* Finish GCS integration into page 3
* Test setup_wizard.py again and initial cold start procedure
