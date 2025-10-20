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
 - posts (2Mb + 0.1Mb + 0.000005Mb)*500K ≈ 1Tb
 - comments (0,00015Mb * 50)*500K ≈ 0.0036Tb
 - reactions: (0.000004Mb*3)*500K ≈ 0.000002Tb

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