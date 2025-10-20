### System requirements

## Functional:
- User can create user’s profile
- Users can publish posts
- Each post can contain: photos, brief text description, wgs84 coordinates 
- Users can add comments to the other users’ posts and set marks
- A comment is a short text, a mark is a number from 1 to 10
- Users can follow other users
- Users can search for popular traveling locations and read posts of other users about these places
- Users can look up users’ feeds 
- User’s feed should be organized as least resent post first 

## Non functional:
- System should be able to scale out together with increasing number of users, hence the number of data (posts, comments… ) horizontal scaling with the system growth, anticipate increased users activities at summer time and in period of holidays(new year, 1-10 in may, etc..)
- System should guarantee survival or at least fast recovery after failures, avoid a single point of failure 
- System should provide data consistency(e.g. comments appear in order of creation, eventual consistency is acceptable) and durability(users data must preserve unless they remove it themselves)
- System should keep a sufficient level of performance (fast page/image loading on web/mobile version) 

## System load assessment:
# 10M unique users +20% per year
- Users profile: 1 photo(2Mb), text description(0.5Mb), small form bio(0.01Mb)
- Posts: up to 50 HD images(2Mb), text description(0.1Mb), coordinates(0.000005Mb)   
- Comments: text(0,00015Mb), mean 50 per post
- Marks: for each post 1 rating(0.000004Mb), other reactions likes, dislikes (0.000004Mb)
- Followers: keep list of followees 3M(0.000004Mb) and followers 3M(0.000004Mb)  
- Feed: keep list of posts 200(0.000008Mb) for each user

# System requires to keep (deadweight):
 - user's profile: (2Mb + 0.5Mb + 0.01Mb)*10M ≈ 24Tb + (20% year growth) ≈ 5Tb
 - followers: (0.000004Mb*500)*10M ≈ 20Gb max, in reality much smaller  
 - followee: (0.000004Mb*500)*10M ≈ 20Gb max, in reality much smaller
 - 1% super popular user with 1M followers +≈ 1Tb
 - feed: (0.000008Mb*200)*10M ≈ 0.015Tb (renew at some interval, doesn't require new space each time)
# Expected DAU is 4M suppose that 500K create posts and leave comments:
 - posts (2Mb + 0.1Mb + 0.000005Mb)\*500K ≈ 1Tb
 - comments (0,00015Mb \* 50)\*500K ≈ 0.0036Tb
 - reactions: (0.000004Mb\*3)\*500K ≈ 0.000002Tb

# Traffic: 
 - write: 1Tb + 0.0036Tb + 0.000002Tb ≈ 1.004Tb/day 
 - read: 8 * write ≈ 8.03Tb/day 

# RPS:
 - write: 1post\*500K + 50comments\*500K + 3reactions\*500K + 2subscribe\*500K = 28000event/day / 86400 ≈ 330 
 - read: 8 * write ≈ 2600

# Storage space required:
  ## HDD:  
    ### Capacity:
        - write + read + deadweight ≈ (1.004+8.03)Tb/day * 365 + (5+1)Tb ≈ 3.3Pb    -> 105 Discs
    ### IOPS:
        - approximately RPS(read+write): 330 + 2600 ≈ 3000                          -> 30 Disc
    ### Thoughput: 
        - (1.004+8.03)Tb/day ≈ 9040000 / 86400 ≈ 105Mb/s                            -> 1 Disc

  ## SSD(SATA):  
    ### Capacity:
        - write + read + deadweight ≈ (1.004+8.03)Tb/day * 365 + (5+1)Tb ≈ 3.3Pb    -> 4 Discs
    ### IOPS:
        - approximately RPS(read+write): 330 + 2600 ≈ 3000                          -> 3 Disc
    ### Thoughput: 
        - (1.004+8.03)Tb/day ≈ 9040000 / 86400 ≈ 105Mb/s                            -> 1 Disc
    
  ## SSD(nVME):  
    ### Capacity:
        - write + read + deadweight ≈ (1.004+8.03)Tb/day * 365 + (5+1)Tb ≈ 3.3Pb    -> 110 Discs
    ### IOPS:
        - approximately RPS(read+write): 330 + 2600 ≈ 3000                          -> 1 Disc
    ### Thoughput: 
        - (1.004+8.03)Tb/day ≈ 9040000 / 86400 ≈ 105Mb/s                            -> 1 Disc

# Distributed storage of data:
    ## Replication:
        - Eventual consistency is enough in case of our requirements. 
        - Master-slave replication with asynchronous copy

    ## Sharding:
        - Database dependent sharding strategy

    ## Cache:
        - Each shard has it's own cache 
        - Cache strategy is cache-aside
        - Cache update is LRU

# Hosts:
    ## Interactions:
        write:
            - posts (2Mb + 0.1Mb + 0.000005Mb)\*500K ≈ 1Tb
            - comments (0,00015Mb \* 50)\*500K ≈ 0.0036Tb
            - reactions: (0.000004Mb\*3)\*500K ≈ 0.000002Tb
        read:
            - posts (2Mb + 0.1Mb + 0.000005Mb)\*4M ≈ 8.2Tb
            - comments (0,00015Mb \* 50)\*4M ≈ 0.03Tb
            - reactions: (0.000004Mb\*3)\*4M ≈ 0.00005Tb
        read+write:
            - posts 1Tb + 8.2Tb ≈ 9.2Tb 
            - comments 0.0036Tb + 0.03Tb ≈ 0.04Tb
            - reactions 0.000002Tb + 0.00005Tb ≈ 0.00006Tb
        static_data(deadweight):
            - user_profiles 5Tb
            - followers 1Tb
        overall:
            - posts         9.2Tb       |           |  3.4Pb    ->  104 HDD  
            - comments      0.04Tb      |  * 365 ≈  |  15Tb     ->    1 HDD
            - reactions     0.00006Tb   |           |  0.02Tb   ->    1 HDD
            - user_profiles 5Tb                        5Tb      ->    1 HDD
            - followers     1Tb                        1Tb      ->    1 HDD

    ## Storage:
        ### posts:
            - 104HDD
            - hosts:
                3 shards (RAID5 + replication factor 3) = (104 / 3) * 3 * 1.2 =     157
                RAID5 reduces capacity by 20%
        ### comments:
            - 1 HDD
            - hosts:
                2 shards (RAID5 + replication factor 3) = (1/2) * 3 * 1.2 =         2 
        ### reactions:
            - 1 HDD
            - hosts:
                2 shards (RAID5 + replication factor 3) = (1/2) * 3 * 1.2 =         2
        ### user_profiles:
            - 1 HDD
            - hosts:
                RAID5 + replication factor 3 = 1 * 3 * 1.2 =                        4 
        ### followers:
            - 1 HDD
            - hosts:
                RAID5 + replication factor 3 = 1 * 3 * 1.2 =                        4

        Overall hosts: 157 + 2 + 2 + 4 + 4 = 169