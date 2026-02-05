#1770243494
gcloud storage cp gs://cloud-training/OCBL453/photo-discovery/ag-web.zip ~ && unzip ~/ag-web -d ~ && rm ~/ag-web.zip
#1770243515
ls ~/ag-web/app
#1770243528
sed -i 's/GCP_PROJECT_ID/qwiklabs-gcp-01-517fc49314f1/' ~/ag-web/app/app.py
#1770243528
sed -i 's/GCP_REGION/us-central1/' ~/ag-web/app/app.py
#1770243528
sed -i 's/GCS_BUCKET/qwiklabs-gcp-01-517fc49314f1-lab-bucket/' ~/ag-web/app/app.py
#1770243621
sed -i 's/SEARCH_ENGINE_ID/goog-merch-ds_1770243082233/' ~/ag-web/app/app.py
#1770243774
cd ~/ag-web/app
#1770243785
gcloud auth login
#1770243891
chmod a+x deploy.sh; ./deploy.sh qwiklabs-gcp-01-517fc49314f1 us-central1
#1770244169
cd ..
#1770244204
git init
#1770244222
git add .
#1770244324
git commit -m "feat: built and deployed app to cloud run"
#1770244380
git remote add origin https://github.com/LennyBeto/flutter-app-ai-integration
#1770244390
git branch -M main
#1770244399
git push -u origin main
#1770244464
git push -u -f origin main
#1770244691
git push -f origin main
#1770245149
git add flutter
#1770245173
git commit -m "feat: modified files in flutter"
#1770245265
git add flutter
#1770245271
git status
#1770245321
git commit -a "feat: flutter directory added"
#1770245352
git commit -m "feat: flutter added"
#1770246695
cat << EOF >> ~/ag-web/app/app.py
#
# Reasoning Engine
#
NB_R_ENGINE_ID = "6655642950090883072"

from vertexai.preview import reasoning_engines
remote_agent = reasoning_engines.ReasoningEngine(
    f"projects/{PROJECT_ID}/locations/{LOCATION}/reasoningEngines/{NB_R_ENGINE_ID}"
)

# Endpoint for the Flask app to call the Agent
@app.route("/ask_gemini", methods=["GET"])
def ask_gemini():
    query = request.args.get("query")
    log.info("[ask_gemini] query: " + query)
    retries = 0
    resp = None
    while retries < MAX_RETRIES:
        try:
            retries += 1
            resp = remote_agent.query(input=query)
            if (resp == None) or (len(resp["output"].strip()) == 0):
                raise ValueError("Empty response.")
            break
        except Exception as e:
            log.error("[ask_gemini] error: " + str(e))
    if (resp == None) or (len(resp["output"].strip()) == 0):
        raise ValueError("Too many retries.")
        return "No response received from Reasoning Engine."
    else:
        return resp["output"]
EOF

#1770246764
sed -i 's/REASONING_ENGINE_ID/6655642950090883072/' ~/ag-web/app/app.py
#1770246836
cd ~/ag-web/app
#1770246846
./deploy.sh qwiklabs-gcp-01-517fc49314f1 us-central1
#1770247082
cd ~; flutter create chat_app
#1770248785
BACKEND_APP_HOST=$(gcloud run services describe ag-web --region us-central1 --format 'value(status.url)' | cut -d'/' -f3);
#1770248790
echo $BACKEND_APP_HOST
#1770248801
mkdir ~/chat_app/assets
#1770248814
cat <<EOF > ~/chat_app/assets/config.json
{
    "cloudRunHost": "$BACKEND_APP_HOST"
}
EOF

#1770248841
cd ~/chat_app
#1770248851
flutter pub get
#1770248866
fwr
#1770249034
flutter pub get
#1770249048
fwr
#1770249493
flutter pub get
#1770249506
fwr
#1770249717
cd ..
