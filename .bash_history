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
