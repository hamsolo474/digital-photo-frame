import os
import sys

import pygame
import random
import socket as s
import threading
import configparser
import socketserver
from PIL import Image

class App:
    def __init__(self):
        pygame.init()
        # self.displayName = True
        # self.orientation_lock = False
        # self.interface = 'localhost'
        # self.port = 9999
        # self.duration = 2
        # self.paths = ['/home/ham/Pictures/Photos']
        self.name = "hamsolo474's Digital Photo Frame"
        self.version = 1
        self.duration_prev = 0
        self.paths = []
        self.config_path = '.dpf_config.ini'
        info = pygame.display.Info()
        self.res = (info.current_w, info.current_h)
        self.read_config()
        self.imglist = []
        for path in self.paths:
            self.imglist.extend([os.sep.join([path, i]) for i in os.listdir(path) if i.lower().endswith(('.jpg', '.png', '.jpeg', '.bmp'))])
        self.screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
        if not self.imglist:
            print("No images found in the folder.")
            exit(1)
        self.clock = pygame.time.Clock()
        self.current_image_index = 0
        self.last_image_change_time = pygame.time.get_ticks()
        self.load_new_image()

    def main(self):
        running = True
        while running:
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False
                    print('Trying to close')
                elif event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_ESCAPE:
                        running = False
                        print('Trying to close')
                    elif event.key == pygame.KSCAN_ESCAPE:
                        running = False
                        print('Trying to close')

            current_time = pygame.time.get_ticks()
            if current_time - self.last_image_change_time >= self.duration*1000:
                self.last_image_change_time = current_time
                self.current_image_index = (self.current_image_index + 1) % len(self.imglist)
                self.load_new_image()

            self.screen.fill((0, 0, 0))
            self.screen.blit(self.image, ((self.res[0] - self.image.get_width()) //2,
                                          (self.res[1] - self.image.get_height())//2))
            font = pygame.font.Font(None, 36)
            text = font.render(self.imglist[self.current_image_index].split(os.sep)[-1] if self.displayName else "",
                               True, (255, 255, 255))
            self.screen.blit(text, (0, 0))
            pygame.display.flip()
            # Cap the framerate
            self.clock.tick(100)
        pygame.quit()
        sys.exit(0)
        quit(0)
        exit(0)

    def load_new_image(self):
        while True:
            try:
                pillow_image = Image.open(self.imglist[self.current_image_index])
                break
            except FileNotFoundError:
                self.imglist.pop(self.current_image_index)
                self.current_image_index = self.current_image_index % len(self.imglist)

        exif_data = pillow_image.getexif()
        orientation = exif_data.get(274, 1)
        match orientation:
            case 2:
                pillow_image = pillow_image.transpose(Image.FLIP_LEFT_RIGHT)
            case 3:
                pillow_image = pillow_image.rotate(180)
            case 4:
                pillow_image = pillow_image.transpose(Image.FLIP_TOP_BOTTOM)
            case 5:
                pillow_image = pillow_image.transpose(Image.FLIP_LEFT_RIGHT).rotate(90)
            case 6:
                pillow_image = pillow_image.rotate(270)
            case 7:
                pillow_image = pillow_image.transpose(Image.FLIP_TOP_BOTTOM).rotate(90)
            case 8:
                pillow_image = pillow_image.rotate(90)
        self.image = pygame.image.fromstring(pillow_image.tobytes(), pillow_image.size, pillow_image.mode)
        imW = self.image.get_width()
        imH = self.image.get_height()
        # Handles both scaling up and down???
        scale_factor = min((self.res[0]) / imW,
                           (self.res[1]) / imH)
        self.image = pygame.transform.scale(self.image, (int(imW * scale_factor), int(imH * scale_factor)))
        if self.orientation_lock:  # Filter images of the wrong orientation
            if imW > imH and self.orientation == 'portrait':
                self.current_image_index += 1
                self.load_new_image()
            elif imH > imW and self.orientation == 'landscape':
                self.current_image_index += 1
                self.load_new_image()
        print(f'Loaded {self.imglist[self.current_image_index]}, orientation {orientation}')


    def next(self):
        self.last_image_change_time = pygame.time.get_ticks()
        self.current_image_index = (self.current_image_index + 1) % len(self.imglist)

    def prev(self):
        self.last_image_change_time = pygame.time.get_ticks()
        self.current_image_index = (self.current_image_index - 1) % len(self.imglist)

    def display_name(self):
        self.displayName = not self.displayName

    def set_delay(self, secs):
        self.duration = float(secs)

    def read_config(self):
        config = configparser.ConfigParser()
        config.read(self.config_path)
        self.duration = float(config.get('Settings', 'SlideDuration', fallback=10))
        self.duration_config = self.duration
        self.displayName = True if config.get('Settings', 'ShowFileName').upper() == 'TRUE' else False
        self.orientation_lock = True if config.get('Settings', 'OrientationLock').upper() == 'TRUE' else False
        self.orientation = config.get('Settings', 'ScreenOrientation').lower()
        if self.orientation not in ['portrait', 'landscape']:
            self.orientation = 'landscape' if self.res[0] > self.res[1] else 'portrait'  # Auto
        self.port = int(config.get('Settings', 'ListenPort', fallback=9999))
        self.interface = config.get('Settings', 'ListenInterface', fallback='localhost')
        counter = 0
        while True:
            path = config.get('Settings', f'PhotoPath{counter}', fallback=None)
            if path:
                self.paths.append(path)
            else:
                break
            counter += 1

    def delete_photo(self):
        os.rename(self.imglist[self.current_image_index], self.imglist[self.current_image_index]+'_MARKED_FOR_DELETION')

    def order(self, key):
        match key.lower().strip():
            case 'asc':
                self.imglist.sort()
            case 'desc':
                self.imglist.sort(reverse=True)
            case 'shuffle':
                random.shuffle(self.imglist)
        self.current_image_index = 0


class MyUDPHandler(socketserver.BaseRequestHandler):
    def handle(self):
        data = self.request[0].strip().decode('utf-8')
        socket = self.request[1]
        op = ""
        global app
        d = data.split()[0].strip()

        match d:
            case 'display_name':
                app.display_name()
                op = app.displayName
            case 'next':
                app.next()
                op = ''
            case 'prev':
                app.prev()
                op = ''
            case 'delay':
                app.set_delay(float(data.split()[1].strip()))
                op = ''
            case 'order':
                app.order(' '.join(data.split()[1:]))
                op = ''
            case 'delete':
                app.delete_photo()
                op = ''
            case 'pause':
                app.set_delay(9999999)
                op = ''
            case 'resume':
                app.set_delay(app.duration_config)
            case 'identify':
                hostname = s.gethostname()
                op = f'{app.name}: Version {app.version} Running on {hostname}'
            case 'exit':
                print('EXITING...')
                sys.exit(0)
        socket.sendto(bytes(f'RECV {data} {op}', 'utf-8'), self.client_address)

def start_udp_server():
    with socketserver.UDPServer((app.interface, app.port), MyUDPHandler) as server:
        server.serve_forever()

if __name__ == '__main__':
    app = App()
    udp_thread = threading.Thread(target=start_udp_server)
    udp_thread.daemon = True
    udp_thread.start()
    app.main()
    exit(0)
