import boto3

# Create S3 client
s3_client = boto3.client('s3')

# List all buckets
print("🔹 Listing S3 Buckets:")
response = s3_client.list_buckets()

for bucket in response['Buckets']:
    print(f" - {bucket['Name']}")

# Count objects in a specific bucket
bucket_name = input("\n🔸 Enter a bucket name to count objects: ")

s3_resource = boto3.resource('s3')
bucket = s3_resource.Bucket(bucket_name)

print(f"\n📦 Counting objects in bucket: {bucket_name} ...")
object_count = sum(1 for _ in bucket.objects.all())
print(f"✅ Total objects in '{bucket_name}': {object_count}")
