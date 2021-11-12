# Backup Databases

Backup databases to an S3 bucket.

### Getting Started

1. Create a new workflow file `.github/workflows/backup-databases.yml`
2. Add the following:

```yaml
name: Backup Databases

on:
  push:
    branches:
      - main
  schedule:
    - cron: 0 */12 * * *

jobs:
  backup-databases:
    runs-on: ubuntu-latest

    steps:
      - name: Backup Databses
        uses: finer-vision/backup-databases@v0.0.32
        with:
          DB_USER: ${{ secrets.UAT_DB_USER }}
          DB_PASSWORD: ${{ secrets.UAT_DB_PASSWORD }}
          DB_HOST: ${{ secrets.UAT_DB_HOST }}
          S3_BUCKET_NAME: ${{ secrets.S3_BUCKET_NAME }}
          S3_FOLDER: ${{ secrets.UAT_S3_FOLDER }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
```

3. Create secrets in your repo's settings
4. Push to your `main` branch to trigger a first run

> Note: workflow scheduling only works when the workflow has been pushed to `main` and run successfully once. Also note, the scheduling isn't completely reliable
