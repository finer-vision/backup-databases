const core = require("@actions/core");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
const mysql = require("mysql2");

function getDatabases(connection) {
  return new Promise((resolve, reject) => {
    connection.query("SHOW DATABASES;", (err, results) => {
      if (err) {
        return reject(err);
      }
      resolve(results);
    });
  });
}

(async () => {
  try {
    const host = core.getInput("DB_HOST");
    const user = core.getInput("DB_USER");
    const password = core.getInput("DB_PASSWORD");
    const bucket = core.getInput("S3_BUCKET_NAME");
    const folder = core.getInput("S3_FOLDER");
    const region = core.getInput("AWS_REGION");
    const accessKeyId = core.getInput("AWS_ACCESS_KEY_ID");
    const secretAccessKey = core.getInput("AWS_SECRET_ACCESS_KEY");

    const ignoredDatabases = [
      "Database",
      "mysql",
      "information_schema",
      "performance_schema",
      "cond_instances",
    ];

    const client = new S3Client({
      region,
      credentials: {
        accessKeyId,
        secretAccessKey,
      },
    });

    const connection = mysql.createConnection({
      host,
      user,
      password,
    });

    const mysqlDatabases = await getDatabases(connection);

    const databases = mysqlDatabases
      .map((database) => {
        return database.Database;
      })
      .filter((database) => {
        return !ignoredDatabases.includes(database);
      });

    const outputDir = path.resolve(__dirname, "tmp");
    execSync(`mkdir -p ${outputDir}`, { stdio: "inherit" });

    await Promise.all(
      databases.map(async (database) => {
        const filename = `${database}.sql`;
        const outputFile = path.join(outputDir, filename);
        try {
          execSync(
            `mysqldump -h "${host}" -u "${user}" -p"${password}" "${database}" > "${outputFile}"`,
            { stdio: "inherit" }
          );
          await client.send(
            new PutObjectCommand({
              Bucket: bucket,
              Key: `${folder}/${filename}`,
              Body: fs.readFileSync(outputFile),
            })
          );
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
