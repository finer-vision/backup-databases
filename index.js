const core = require("@actions/core");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");

(async () => {
  try {
    const username = core.getInput("DB_USER");
    const password = core.getInput("DB_PASSWORD");
    const host = core.getInput("DB_HOST");
    const bucket = core.getInput("S3_BUCKET_NAME");
    const folder = core.getInput("S3_FOLDER");
    const region = core.getInput("AWS_REGION");
    const accessKeyId = core.getInput("AWS_ACCESS_KEY_ID");
    const secretAccessKey = core.getInput("AWS_SECRET_ACCESS_KEY");

    const ignoredDatabases = [
      "",
      "Database",
      "mysql",
      "information_schema",
      "performance_schema",
      "cond_instances",
    ];

    const mysqlDatabases = execSync(
      `/usr/bin/echo "show databases;" | /usr/bin/mysql -h "${host}" -u "${username}" -p"${password}"`,
      { stdio: "pipe" }
    );

    const databases = mysqlDatabases
      .toString("utf-8")
      .split("\n")
      .filter((database) => {
        return !ignoredDatabases.includes(database);
      });

    const outputDir = path.resolve(__dirname, "tmp");
    execSync(`mkdir -p ${outputDir}`, { stdio: "inherit" });

    const client = new S3Client({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });

    await Promise.all(
      databases.map(async (database) => {
        const filename = `${database}.sql`;
        const outputFile = path.join(outputDir, filename);
        try {
          execSync(
            `/usr/bin/mysqldump -h "${host}" -u "${username}" -p"${password}" "${database}" > "${outputFile}"`,
            { stdio: "pipe" }
          );
          await client.send(
            new PutObjectCommand({
              Bucket: bucket,
              Key: `${folder}/${filename}`,
              Body: fs.readFileSync(outputFile),
            })
          );
          execSync(`rm -f ${outputFile}`);
        } catch (err) {
          console.error(err);
        }
      })
    );
    process.exit(0);
  } catch (err) {
    console.error(err);
    core.setFailed(err.message);
    process.exit(1);
  }
})();
