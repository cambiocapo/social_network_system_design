// Relatinal database: e.g. PostgreSQL

Table follows {
  followee_user_id integer
  followed_user_id integer
}

Table users {
  id integer [primary key]
  username varchar
  rating integer
  created_at timestamp
}

Table reactions {
  post_id integer [primary key]
  user_id integer
  like bool
  dislike bool
  comment text [note: 'Content of the comment']
  created_at timestamp
  updated_at timestamp
}

Table posts {
  id integer [primary key]
  title varchar
  body text [note: 'Content of the post']
  user_id integer [not null]
  status varchar
  created_at timestamp
  updated_at timestamp
}

Ref user_posts: posts.user_id > users.id // many-to-one
Ref: users.id < follows.followee_user_id
Ref: users.id < follows.followed_user_id
Ref: posts.id < reactions.post_id
Ref: users.id < reactions.user_id



// Replication:
// - master-slave replication type
// - asynchronous replication 
// - replication factor 3

// Sharding:
// - horizontal key based Sharding
// - 2 shards

// Cache:
// - 10000 post_id a located in Cache
// - Least recent quired post_id replaced at each new query
 