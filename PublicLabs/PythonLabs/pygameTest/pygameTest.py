
import sys, pygame
from pygame.locals import *

pygame.init()
screenSize = width, height = 800, 600
black = 0,0,0
screen = pygame.display.set_mode(screenSize)

playerSpeed = [2, 2]
player = pygame.image.load("unnamed.png")
playerRect = player.get_rect()

while 1:
    for event in pygame.event.get():
        if event.type == pygame.QUIT: sys.exit()

        playerRect = playerRect.move(playerSpeed)
        screen.fill(black)
        screen.blit(player, playerRect)
      

