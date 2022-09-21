from math import sqrt
import copy
from curses import KEY_BACKSPACE
import glfw
from OpenGL.GL import *
cx = 0
cy = 0
size = 700
t = 150
points = []
newPoints = []
pSize = size * size * 3
pixels = [0]*pSize
def setPixel(x, y, r, g, b):
    y1 = y * -1
    x1 = x
    y1 += round(size/2)
    x1 += round(size/2)
    y1 = size  - y1
    position =  (x1 + y1 * size) * 3
    pixels[position] = r
    pixels[position + 1] = g
    pixels[position + 2] = b

def dark_bresenham(x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1    
    sign_x = 1 if dx>0 else -1 if dx<0 else 0
    sign_y = 1 if dy>0 else -1 if dy<0 else 0

    if dx < 0: dx = -dx
    if dy < 0: dy = -dy
        
    if dx > dy:
        pdx, pdy = sign_x, 0
        es, el = dy, dx
    else:
        pdx, pdy = 0, sign_y
        es, el = dx, dy
        
    x, y = x1, y1
        
    error, t = el/2, 0             
    setPixel(x, y, 0, 0, 0)
    while t < el:
        error -= es
        if error < 0:
            error += el
            x += sign_x
            y += sign_y
        else:
            x += pdx
            y += pdy
        t += 1
        setPixel(x, y, 0, 0, 0)

def bresenham(x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1    
    sign_x = 1 if dx>0 else -1 if dx<0 else 0
    sign_y = 1 if dy>0 else -1 if dy<0 else 0

    if dx < 0: dx = -dx
    if dy < 0: dy = -dy
        
    if dx > dy:
        pdx, pdy = sign_x, 0
        es, el = dy, dx
    else:
        pdx, pdy = 0, sign_y
        es, el = dx, dy
        
    x, y = x1, y1
        
    error, t = el/2, 0             
    setPixel(x, y, 255, 255, 255)
    while t < el:
        error -= es
        if error < 0:
            error += el
            x += sign_x
            y += sign_y
        else:
            x += pdx
            y += pdy
        t += 1
        setPixel(x, y, 255, 255, 255)


def display(window):
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glDrawPixels(size, size, GL_RGB, GL_UNSIGNED_BYTE, pixels)
    glfw.swap_buffers(window)
    glfw.poll_events()

def key_callback(window, key, scancode, action, mods):
    global pixels
    global points
    global pointsScan
    global pSize
    if action == glfw.PRESS:
        if key == glfw.KEY_ENTER:
            draw_lines()
        if key == glfw.KEY_BACKSPACE:
            cut_lines()    
        

def cursor_pos(window, xpos, ypos):
    global cx
    global cy
    cx = xpos - round(size/2)
    cy = ypos - round(size/2)
    cy *= -1
def set_code(x, y):
    if x > t and y > t:
        return 10
    if y >= t and x < t and x > -t:
        return 8
    if y > t and x < -t:
        return 9
    if x <= -t and y < t and y > -t:
        return 1
    if x < -t and y < -t:
        return 5
    if y <= -t and x < t and x > -t:
        return 4
    if y < -t and x > t:
        return 6
    if x >= t and y < t and y > -t:   
        return 2
    if x > -t and x < t and y > -t and y < t:
        return 0 
    return 0                       

def cut_line(x1, y1, x2, y2):
    global newPoints
    c1 = set_code(x1, y1)
    c2 = set_code(x2, y2)

    if c1 == 0 and c2 == 0:
        return      
    if c1 & c2 != 0:
        newPoints.append([x1, y1])
        newPoints.append([x2, y2])
        return

    points_p = []
    xmin = min(x1, x2)
    xmax = max(x2, x2)
    ymin = min(y1, y2)
    ymax = max(y1, y2)
    yp1 = t
    xp1 = round((yp1 - y1) * (x2-x1)/(y2 - y1)) + x1   
    if xp1 <= t and xp1 >= -t and xp1 <= xmax and xp1 >= xmin and yp1 <= ymax and yp1 >= ymin:
        points_p.append([xp1, yp1])


    yp2 = -t  
    xp2 = round((yp2 - y1) * (x2-x1)/(y2 - y1)) + x1 
    if xp2 <= t and xp2 >= -t and xp2 <= xmax and xp2 >= xmin and yp2 <= ymax and yp2 >= ymin :
        points_p.append([xp2, yp2])
    
    xp3 = t
    yp3 = round((xp3 - x1) * (y2 - y1) / (x2-x1)) + y1
    if yp3 <= t and yp3 >= -t and xp3 <= xmax and xp3 >= xmin and yp3 <= ymax and yp3 >= ymin:
        points_p.append([xp3, yp3])

    xp4 = -t
    yp4 = round((xp4 - x1) * (y2 - y1) / (x2-x1)) + y1
    if yp4 <= t and yp4 >= -t and xp4 <= xmax and xp4 >= xmin and yp4 <= ymax and yp4 >= ymin:
        points_p.append([xp4, yp4])
    for i in range (len(points_p)):
        r1 = round(sqrt(pow(points_p[i][0] - x1, 2) + pow(points_p[i][1] - y1, 2)))
        r2 = round(sqrt(pow(points_p[i][0] - x2, 2) + pow(points_p[i][1] - y2, 2)))
        if r1 > r2:
            if c2 !=0:
                cut_line(points_p[i][0], points_p[i][1], x2, y2) 
            else:
                cut_line(x1, y1, points_p[i][0], points_p[i][1]) 
        else:
            if c1 != 0: 
                cut_line(x1, y1, points_p[i][0], points_p[i][1])
            else:            
                cut_line(points_p[i][0], points_p[i][1], x2, y2)







def draw_lines():
    if len(points) % 2 == 0:
        for i in range(0, len(points), 2):
            bresenham(points[i][0], points[i][1], points[i+1][0], points[i+1][1])

def cut_lines():
    if len(points) % 2 == 0:
        for i in range(0, len(points), 2):
            cut_line(points[i][0], points[i][1], points[i+1][0], points[i+1][1])
        redraw()    

def redraw():
    global points
    global newPoints
    global pSize
    global pixels   
    points = newPoints
    pixels = [0]*pSize
    bresenham(t, t, t, -t)
    bresenham(t, -t, -t, -t)
    bresenham(-t, -t, -t, t)
    bresenham(-t, t, t, t)
    draw_lines()

def mouse_button(window, button, action, mods):
    global draw
    global points
    if action == glfw.PRESS:
        if button == glfw.MOUSE_BUTTON_LEFT:
            setPixel(round(cx), round(cy), 255, 255, 255)
            points.append([round(cx), round(cy)])




def main(): 
    global t
    if not glfw.init():
        return
    window = glfw.create_window(size, size, "l4", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glfw.set_cursor_pos_callback(window, cursor_pos)
    glfw.set_mouse_button_callback(window, mouse_button)
    glClearColor(1.0, 1.0, 1.0, 1.0)
    bresenham(t, t, t, -t)
    bresenham(t, -t, -t, -t)
    bresenham(-t, -t, -t, t)
    bresenham(-t, t, t, t)
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


main()