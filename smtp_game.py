import terminal_api
import os
import time
import platform
settings_filename = 'client_settings.txt'

smtpcommand = 'HELO'
mode = 'command'
email = []
def reset():
    global smtpcommand
    global mode
    global email
    smtpcommand = 'HELO'
    mode = 'command'
    email = []


terminal = 'game'
console = terminal_api.console
console.print('Connecting to server...')

current_os = "Windows"
if platform.system() != "Windows":
    current_os = "Other"
    os.system('clear')
else:
    os.system('cls')
    os.system('mode con: cols=98 lines=20')

if terminal_api.connect(terminal):
    console.print('Connected.')
    team_colour = terminal_api.team_colour

    terminal_api.prompt = f"[{team_colour}]SMTP[/{team_colour}]@[{team_colour}]{terminal_api.game_ip_address}[/{team_colour}]>"

    message = ''

    




    while message != 'quit':


        console.print('''
        __________________________
        |\                      /|
        | \        ASCII       / |
        |  \  (/◕ヮ◕)/ (◠‿◠)  /  | 
        |  /\________________/\  | 
        | /                    \ | 
        |/                      \|
        |________________________| 

                        ''')


        message = console.input(terminal_api.prompt)
        if message == 'HELO':
            if smtpcommand == 'HELO':
                mode = 'email'
                smtpcommand = 'MAIL FROM'
                
            else:
                print("Syntax Error")
                reset()


        elif mode == 'email':
            
            if message.startswith('MAIL FROM:'):
                if smtpcommand == 'MAIL FROM':
                    smtpcommand = 'RCPT TO'
                    email.append(message)
                    
                else:
                    print("Syntax Error")
                    reset()

            elif message.startswith('RCPT TO:'):
                if smtpcommand == 'RCPT TO':
                    smtpcommand = 'DATA'
                    email.append(message)
                    
                else:
                    print("Syntax Error")
                    reset()

            elif message.startswith('DATA'):
                if message.endswith('.'):
                    email.append(message)
                    terminal_api.send(email)
                else:
                    print("Syntax Error")
                    reset()
            else:
                print('Syntax Error')
                reset()

            
        elif message.startswith('rem:'):
            reset()
            terminal_api.remove_item(message[4:])
        else:
            reset()
            terminal_api.send(message)
        time.sleep(0.2)
    terminal_api.disconnect()
else:
    console.print("Failed to connect.")
