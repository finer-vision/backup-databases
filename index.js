const core = require("@actions/core");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");

try {
  const bucket = core.getInput("S3_BUCKET_NAME");
  const folder = core.getInput("S3_FOLDER");
  const region = core.getInput("AWS_REGION");
  const accessKeyId = core.getInput("AWS_ACCESS_KEY_ID");
  const secretAccessKey = core.getInput("AWS_SECRET_ACCESS_KEY");

  // a client can be shared by different commands.
  const client = new S3Client({
    region,
    credentials: {
      accessKeyId,
      secretAccessKey,
    },
  });

  const filename = "test";

  (async () => {
    try {
      await client.send(
        new PutObjectCommand({
          Bucket: bucket,
          Key: `${folder}/${filename}`,
          Body: Buffer.from("this is a test"),
        })
      );
    } catch (err) {
      console.error(err);
    }
  })();
} catch (err) {
  console.error(err);
  core.setFailed(err.message);
}
