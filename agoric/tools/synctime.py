import requests
from time import sleep
from datetime import datetime, timedelta

my_rpc = 'http://localhost:26657'
test_time = 5 # test for 5 minutes


def average(lst):
    return round(sum(lst) / len(lst), 1)


def get_block_height(url):
    url = f"{url}/status"
    return int(requests.get(url=url).json()['result']['sync_info']['latest_block_height'])
    

def get_sync_status(url):
    url = f"{url}/status"
    return int(requests.get(url=url).json()['result']['sync_info']['catching_up'])


def get_peer_count(url):
    url = f"{url}/net_info"
    return len(requests.get(url=url).json()['result']['peers'])


if get_sync_status(my_rpc) == False:
    print('Your node is already synced!')
else:
    peer_count = get_peer_count(my_rpc)
    current_block = get_block_height(my_rpc)
    latest_block = int(input("Enter latest block height: "))
    blocks_left = latest_block - current_block
    
    print(f'Connected peer count: {peer_count}')
    print(f'Your current block: {current_block}')
    print(f'Latest block: {latest_block}')
    print(f'Blocks left to sync : {blocks_left}')

    print(f'Calculating blocks... Please wait {test_time} minutes for script to finish!')

    result = []
    for _ in range(test_time):
        current_block = get_block_height(my_rpc)
        sleep(60)
        result.append(get_block_height(my_rpc) - current_block)
        avg_blocks_per_min = average(result)
        print(f'({_ + 1}) Last bpm: {result[-1]} Average bpm: {avg_blocks_per_min}')


    min_left = int(blocks_left/avg_blocks_per_min)
    time_left = '{:02d} hours and {:02d} minutes'.format(*divmod(min_left, 60))
    print(f'Average blocks per minute: {avg_blocks_per_min}')
    print(f'Time to reach latest block height: {time_left}')
    now = datetime.now()
    final_time = now + timedelta(minutes=min_left)
    print('Time now: ', now)
    print('Final time: ', final_time)
