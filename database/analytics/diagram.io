// Column-oriented database: e.g. Clickhouse

Table analytics {
  post_id integer
  post_title varchar
  post_body text [note: 'Content of the post']
  post_creation_date timestamp
  user_id integer [not null]
  reaction_type varchar
  comment text  
}