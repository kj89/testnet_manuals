import requests
from time import sleep
from datetime import datetime, timedelta

your_rpc = 'http://localhost:26657/abci_info?'
public_rpc = 'https://rpc-agoric.nodes.guru/abci_info?'
test_time = 10


def average(lst):
    return round(sum(lst) / len(lst), 1)


def get_block(url):
    return int(requests.get(url=url).json()['result']['response']['last_block_height'])


print(f'Calculating blocks... Please wait {test_time} minutes to finish!')

result = []
for _ in range(test_time):
    current_block = get_block(your_rpc)
    sleep(60)
    result.append(get_block(your_rpc) - current_block)
    avg_blocks_per_min = average(result)
    print(f'({_ + 1}) Last bpm: {result[-1]} Average bpm: {avg_blocks_per_min}')

current_block = get_block(your_rpc)
latest_block = get_block(public_rpc)
blocks_left = latest_block - current_block
min_left = int(blocks_left/avg_blocks_per_min)
time_left = '{:02d} hours and {:02d} minutes'.format(*divmod(min_left, 60))
print(f'{latest_block=} {current_block=}')
print(f'Average blocks per minute: {avg_blocks_per_min}')
print(f'Blocks left to sync : {blocks_left}')
print(f'Time to reach latest block height: {time_left}')

now = datetime.now()
final_time = now + timedelta(minutes=min_left)
print('Time now: ', now)
print('Final time: ', final_time)
