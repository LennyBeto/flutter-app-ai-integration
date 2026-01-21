# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Building a photo recognition agent: Reasoning Engine setup

This notebook shows how to setup the Reasoning Engine for the photo recognition agent demo
### Install Vertex AI SDK for Python

Install the latest version of the Vertex AI SDK for Python as well as extra dependencies related to Reasoning Engine and LangChain:
!pip install --upgrade --quiet google-cloud-aiplatform[langchain,reasoningengine]==1.83.0 google-cloud-discoveryengine==0.11.10
### Restart current runtime

To use the newly installed packages in this Jupyter runtime, you must restart the runtime. You can do this by running the cell below, which will restart the current kernel.
# Restart kernel after installs so that your environment can access the new packages
import IPython

app = IPython.Application.instance()
app.kernel.do_shutdown(True)
<div class="alert alert-block alert-warning">
<b>⚠️ The kernel is going to restart. Please wait until it is finished before continuing to the next step. ⚠️</b>
</div>
<div class="alert alert-block alert-warning">
If prompted, in the <b>Kernel Restarting</b> dialog, click <b>Ok</b>.
</div>
### Set Google Cloud project information and initialize Vertex AI SDK

To get started using Vertex AI, you must have an existing Google Cloud project and [enable the Vertex AI API](https://console.cloud.google.com/flows/enableapi?apiid=aiplatform.googleapis.com).

Learn more about [setting up a project and a development environment](https://cloud.google.com/vertex-ai/docs/start/cloud-environment).

Before running this cell to initialize the Vertex AI SDK, update the configuration values for the <b>PROJECT_ID, LOCATION, and STAGING_BUCKET.</b>
PROJECT_ID = "YOUR_LAB_PROJECT_ID"
LOCATION = "YOUR_LAB_REGION"
STAGING_BUCKET = "YOUR_LAB_STAGING_BUCKET"

import vertexai

vertexai.init(project=PROJECT_ID, location=LOCATION, staging_bucket=STAGING_BUCKET)
## Wikipedia Tool
In this section, you'll define multiple Python functions that access the Wikipedia API. Later we'll use these Python functions as Tools in our Reasoning Engine agent.
### Define functions for accessing the Wikipedia API
import requests

# get full text of the wiki page
def get_wiki_full_text(wiki_title):
    # get the page
    url = f"https://en.wikipedia.org/w/api.php?action=query&prop=extracts&titles={wiki_title}&explaintext=true&format=json"
    response = requests.get(url)
    data = response.json()

    # extract plain text
    page_id = next(iter(data["query"]["pages"]))
    plain_text = data["query"]["pages"][page_id]["extract"]
    return plain_text
### Define Tool function for the Wikipedia API
# make a query on Wikipedia for a topic
def query_with_wikipedia(
    query: str = "Fallingwater",
):
    """
    Finds answer for any topic or object from Wikipedia and returns a dictionary containing the answer.

    Args:
        query: the name of object or topic to find.

    Example: {"answer": "Fallingwater is a house designed by the architect Frank Lloyd Wright in 1935."}
    """

    wiki_full_text = get_wiki_full_text(query)  # calls Wikipedia API to get full text
    
    return {"answer": wiki_full_text}
query_with_wikipedia()
## Vertex AI Search Tool
In this section, it will define a Tool for calling the /ask_gms on the Cloud Run for making a query with the Google Merch Shop dataset on Vertex AI Search. So, before using this Tool, you need to deploy the Run instance with /ag-web/app/deploy.sh .
### Define Tool funtion for Vertex AI Search

The Cloud Run host name can be found on Console > Cloud Run > ag-web > URL at the top
from vertexai.preview import reasoning_engines

GOOGLE_SHOP_VERTEXAI_SEARCH_URL = (
    "https://YOUR_BACKEND_APP_CLOUD_RUN_ENDPOINT/ask_gms"  # please change
)
def find_product_from_googleshop(product_name: str, product_description: str):
    """
    Find a product with the product_name and product_description from
    Google Merch Shop and returns a dictionary containing product details.
    """

    params = {"query": product_name + " " + product_description}
    response = requests.get(
        GOOGLE_SHOP_VERTEXAI_SEARCH_URL, params
    )  # calls Vertex AI Search
    item = response.json()
    productDetails = f"""
        {item['title']} is a product sold at Google Merch Shop. The price is {item['price']}. 
        You can buy the product at their web site: {item['link']}.
    """

    return {"productDetails": productDetails}
## Define and deploy the Agent
In this section, it creates an agent with the Wikipedia Tool and Search Tool, and deploy it to the Reasoning Engine runtime.

### Define the agent
model_name = "gemini-2.0-flash-001"
agent = reasoning_engines.LangchainAgent(
    model=model_name,
    tools=[query_with_wikipedia, find_product_from_googleshop],
    agent_executor_kwargs={"return_intermediate_steps": True},
)
### Test it locally
# input_text = "Google Dino Pin. A collectible enamel pin featuring the iconic Lonely T-Rex dinosaur from the Google Chrome browser offline error page. Great product."
# input_text = "Google Bike Enamel Pin. This is a collectible lapel pin featuring a colorful bicycle with a basket, likely representing Google's company culture and its promotion of cycling as a sustainable mode of transportation."
# input_text = "Android Pen. This is a blue ballpoint pen featuring the Android logo. It appears to be a promotional or branded item associated with the Android operating system"
# input_text = "Google Chrome Dinosaur Game Pin. where can i buy it? Write the answer in plaintext."
input_text = (
    "Google Bike Enamel Pin. where can i buy it? Write the answer in plaintext."
)
agent.query(input=input_text)
### Deploy the Agent to the Reasoning Engine runtime
remote_agent = reasoning_engines.ReasoningEngine.create(
    agent,
    requirements=[
        "google-cloud-aiplatform[langchain,reasoningengine]",
        "requests",
    ],
)
### Test it
remote_agent.query(input="Where can I buy the Chrome Dino Rope Lanyard?")
remote_agent.query(input="What is Fallingwater?")
