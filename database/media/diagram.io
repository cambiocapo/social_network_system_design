// Persistent storage: e.g. S3

bucket: media
    - posts_images
    - user_profile_images


// Replication:
// - master-slave replication type
// - asynchronous replication 
// - replication factor 3

// Sharding:
// - horizontal hash based Sharding
// - 5 shards

// Cache:
// - 1000 post_id (and all images related to it) a located in Cache
// - Least recent quired post_id (and all images related to it) replaced at each new query
 