import copy
from curses import KEY_BACKSPACE
import glfw
import math
from OpenGL.GL import *
cx = 0
cy = 0
size = 700
points = []
pointsScan = [0]*size
a = []
for i in range (len(pointsScan)):
    pointsScan[i] = copy.deepcopy(a)
pSize = size * size * 3
pixels = [0]*pSize
def sortByX(xWithClone):
    return xWithClone[0]

def setPixel(x, y, r, g, b):
    position =  (x + y * size) * 3
    pixels[position] = r
    pixels[position + 1] = g
    pixels[position + 2] = b

    
def bresenham2(x1, y1, x2, y2):
    dx = x2 - x1
    dy = y2 - y1    
    sign_x = 1 if dx>0 else -1 if dx<0 else 0
    sign_y = 1 if dy>0 else -1 if dy<0 else 0

    if dx < 0: dx = -dx
    if dy < 0: dy = -dy
    m = (dy / dx)
    if dx > dy:
        pdx, pdy = sign_x, 0
        es, el = dy, dx
    else:
        pdx, pdy = 0, sign_y
        es, el = dx, dy
        m = 1/m
    m *= 256
    w = 256 - m   
    x, y = x1, y1
        
    error, t = 1/2, 0             
    setPixel(x, y, round(m/2), round(m/2), round(m/2))
    while t < el:
        if error > w:
            error -= w
            x += sign_x
            y += sign_y
        else:
            x += pdx
            y += pdy
            error += m
        t += 1
        setPixel(x, y, round(255*(1-(error/255))), round(255*(1-(error/255))), round(255*(1-(error/255))))

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

def initPoints(x1, y1, x2, y2):
    if y1 != y2:
        ymax = y2
        ymin = y1
        if y1 > y2:
            ymax = y1
            ymin = y2
        for y in range(ymin + 1, ymax):
            x = round((y - y1) * (x2-x1)/(y2 - y1)) + x1    
            pointsScan[y].append([x, 0])
   
def makeLines():
    for i in range(len(points)):
        if i == len(points) - 1:
            bresenham2(points[i][0], points[i][1], points[0][0], points[0][1])
            initPoints(points[i][0], points[i][1], points[0][0], points[0][1])
            if (points[0][1] > points[i][1] and points[i-1][1] > points[i][1]) or (points[0][1] < points[i][1] and points[i-1][1] < points[i][1]):
                pointsScan[points[i][1]].append([points[i][0], 1])
            else:
                pointsScan[points[i][1]].append([points[i][0], 0])   
        elif i == 0:
            bresenham2(points[i][0], points[i][1], points[i+1][0], points[i+1][1])
            initPoints(points[i][0], points[i][1], points[i+1][0], points[i+1][1])
            if (points[1][1] > points[0][1] and points[len(points)-1][1] > points[0][1]) or (points[1][1] < points[0][1] and points[len(points)-1][1] < points[0][1]):
                pointsScan[points[i][1]].append([points[i][0], 1])
            else:
                pointsScan[points[i][1]].append([points[i][0], 0])    
        else:
            bresenham2(points[i][0], points[i][1], points[i+1][0], points[i+1][1]) 
            initPoints(points[i][0], points[i][1], points[i+1][0], points[i+1][1])   
            if (points[i+1][1] > points[i][1] and points[i-1][1] > points[i][1]) or (points[i+1][1] < points[i][1] and points[i-1][1] < points[i][1]):
                pointsScan[points[i][1]].append([points[i][0], 1])
            else:
                pointsScan[points[i][1]].append([points[i][0], 0]) 
def drawGorizontalLine(x1, x2, y):
    xs = x1
    xf = x2
    if x1 > x2:
        xs = x2
        xf = x1
    for x in range(xs, xf + 1):
        setPixel(x, y, 255, 255, 255)   
        
def scan():
    for i in range (len(pointsScan)):
        if len(pointsScan[i]) != 0:
            pointsScan[i].sort(key=sortByX)
            j = 0
            while j < len(pointsScan[i]):
                if pointsScan[i][j][1] == 1:
                    pointsScan[i].insert(j + 1, [pointsScan[i][j][0], 0])
                if (j + 1) % 2 != 0:
                    drawGorizontalLine(pointsScan[i][j][0], pointsScan[i][j + 1][0], i)  
                j+=1     

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
            makeLines()
            scan()
        #if key == glfw.KEY_UP:
           # scan()    
        if key == glfw.KEY_BACKSPACE:
            points = []
            pointsScan = [0]*size
            a = []
            for i in range (len(pointsScan)):
                pointsScan[i] = copy.deepcopy(a)
                pixels = [0]*pSize    


def cursor_pos(window, xpos, ypos):
    global cx
    global cy
    cx = xpos
    cy = size - ypos



def mouse_button(window, button, action, mods):
    global draw
    global points
    if action == glfw.PRESS:
        if button == glfw.MOUSE_BUTTON_LEFT:
            setPixel(round(cx), round(cy), 255, 255, 255)
            points.append([round(cx), round(cy)])




def main(): 
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
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


main()