import matplotlib.pyplot as plt
import time
import IPython.display as display

door_pos = {"x": None, "y": None}

def process_state(KB, state):
    KB.retractall("position(agent,_,_)")
    KB.retractall("is_wall(_,_)")
    KB.retractall("stepping_on(agent, _)")
    for i in range(21):
        for j in range(79):
            if not (state['screen_descriptions'][i][j] == 0).all():
                obj = bytes(state['screen_descriptions'][i][j]).decode('utf-8').rstrip('\x00')
                if 'staircase down' in obj:
                    KB.assertz(f'position(exit, {i}, {j})')
                elif 'key' in obj:
                    KB.assertz(f'position(key, {i}, {j})')
                elif 'door' in obj:
                    KB.assertz(f'position(door, {i}, {j})')
                    door_pos["x"] = i
                    door_pos["y"] = j
                elif 'wall' in obj:
                    KB.assertz(f'is_wall({i}, {j})')
                elif 'Agent' in obj:
                    KB.assertz(f'position(agent, {i}, {j})')
                    KB.assertz(f'explored({i}, {j})')
                    if (door_pos["x"] == i and door_pos["y"] == j):
                        KB.assertz('has_entered(agent)')
    message = bytes(state['message']).decode('utf-8').rstrip('\x00')
    print(message)
    if 'You see here' in message:
        if 'key' in message:
            KB.assertz('stepping_on(agent, key)')

ACTIONS = {"north": 0, "east": 1, "south": 2, "west": 3, "northeast": 4, "southeast": 5, "southwest": 6, "northwest": 7, "pick": 8, "open_door": 9}

def get_action(action):
    key = action
    if ("move_towards_goal" in action):
        idx1 = action.index("move_towards_goal(")
        idx2 = action.index(")")
        key = action[idx1 + 18: idx2]
    elif ("move" in action):
        idx1 = action.index("move(")
        idx2 = action.index(")")
        key = action[idx1 + 5: idx2]
    return ACTIONS[key]

def plot_sequence(states, is_little):
    start = states[0][50:325, 480:800]
    if (is_little):
        start = states[0][115:275, 480:750]
    image = plt.imshow(start)
    for state in states[1:]:
        time.sleep(0.25)
        display.display(plt.gcf())
        display.clear_output(wait=True)
        image.set_data(state[115:275, 480:750] if is_little else state[50:325, 480:800])
    time.sleep(0.25)
    display.display(plt.gcf())
    display.clear_output(wait=True)