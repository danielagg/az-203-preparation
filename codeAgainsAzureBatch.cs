namespace TestNamespace
{
    public class Test()
    {
        const string storageConnectionString = $"DefaultEndpointsProtocol=https;AccountName={ STORAGE_ACCOUNT_NAME };AccountKey={ STORAGE_ACCOUNT_KEY }";
        const string STORAGE_ACCOUNT_IMAGES_CONTAINER_NAME = "images";

        public void Main()
        {
            CloudStorageAccount storageAccount = CloudStorageAccount.Parse(storageConnectionString);
            CloudBlobClient blobClient = storageAccount.CreateCloudBlobClient();

            CloudBlobContainer imagesContainer = blobClient
                .GetContainerReference(STORAGE_ACCOUNT_IMAGES_CONTAINER_NAME);
            
            imagesContainer.CreateIfNotExistsAsync().Wait();
        }


    }
}