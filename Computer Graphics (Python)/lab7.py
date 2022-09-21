from curses import KEY_DOWN
import glfw
from OpenGL.GL import *
from math import *
import time
vertex_arr = []
tex_arr = []
n = 0   
# bmp картинка формата 96x96
def read_rows(path):
    image_file = open(path, "rb")
    image_file.seek(54)

    rows = []
    row = []
    pixel_index = 0

    while True:
        if pixel_index == 96:
            pixel_index = 0
            rows.insert(0, row)
            row = []
        pixel_index += 1

        r_string = image_file.read(1)
        g_string = image_file.read(1)
        b_string = image_file.read(1)

        if len(r_string) == 0:
            break


        r = ord(r_string)
        g = ord(g_string)
        b = ord(b_string)

        row.append(b)
        row.append(g)
        row.append(r)

    image_file.close()

    return rows

def repack_sub_pixels(rows):
    sub_pixels = []
    for row in rows:
        for sub_pixel in row:
            sub_pixels.append(sub_pixel)

    diff = len(sub_pixels) - 96 * 96 * 3

    return sub_pixels

rows = read_rows("zebrano02.bmp")
#rows = read_rows("zeder.bmp")
#rows = read_rows("ziricote.bmp")
#rows = read_rows("rosenholz.bmp")
#rows = read_rows("thuya-maser.bmp")
image = repack_sub_pixels(rows)


v0 = 0
g = 0.00049
surface = -3.3
h0 = 0

light = False
move = False
it = False
texture = 0

def generate():
    p = 0
    global n
    global nn
    t = 0
    while t < 1.5  * pi:       
        k = -1.4
        if p == 0:
            tex_arr.append(0)
            tex_arr.append(0)
            p += 1
        elif p == 1:
            tex_arr.append(0)
            tex_arr.append(1)
            p += 1
        elif p == 2:
            tex_arr.append(1)
            tex_arr.append(1)
            p += 1
        elif p == 3:
            tex_arr.append(1)
            tex_arr.append(0)
            p = 0        
        while k < 1.5:
            x = k*cos(t)
            z = k*sin(t)
            y = k*k
            vertex_arr.append(x)
            vertex_arr.append(y)
            vertex_arr.append(z)
            k += 0.1  
            n += 1
        t += 0.1


def draw_figure(x, y, z):
    glScalef(0.3, 0.3, 0.3)
    glTranslatef(x, y, z)
    glCallList(1)



def light_on():
    glCallList(2)
    
def light_display_list():
    glNewList(2, GL_COMPILE)
    material_diffuse = [1, 1.0, 1.0, 1.0] 
    glMaterialfv(GL_FRONT, GL_DIFFUSE, material_diffuse)
    light3_diffuse = [1, 1, 1]
    light3_position = [0.0, 0.0, 1.0, 1.0]
    light3_spot_direction = [0.0, 0.0, -1.0]
    glEnable(GL_LIGHT0)
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light3_diffuse)
    glLightfv(GL_LIGHT0, GL_POSITION, light3_position)
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 10)
    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light3_spot_direction)
    glEndList()

def display(window):
    start = time.monotonic()
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    if light:
        light_on()

    glMatrixMode(GL_MODELVIEW)

    glLoadIdentity()
    if not move:
        glPushMatrix()
        draw_figure(0, 0, 0)
        glPopMatrix()
    if move:
        global h0
        global v0
        glPushMatrix()
        draw_figure(0, h0, 0)
        h0 += v0
        v0 -= g
        if h0 <= surface or h0 > 0:
            v0 = -1 * v0
        glPopMatrix()  

    glfw.swap_buffers(window)
    glfw.poll_events()
    end = time.monotonic()
    print(end - start)

def display_list():
    glNewList(1, GL_COMPILE)
    glTexCoordPointer(2, GL_FLOAT, 0, tex_arr)
    glVertexPointer(3, GL_FLOAT, 0, vertex_arr)
    glDrawArrays(GL_LINE_LOOP, 0, n)
    glEndList()

def key_callback(window, key, scancode, action, mods):
    global an1
    global an2
    global an3
    global sc
    global light
    global move
    if action == glfw.PRESS: 
        if key == glfw.KEY_ENTER:
            if light:
                light = False
                glDisable(GL_LIGHTING)
            else:
                glEnable(GL_LIGHTING)
                glLightModelf(GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE)
                light = True    
        if key == glfw.KEY_DOWN:
            if move:
                global h0
                global v0
                v0 = 0
                h0 = 0
                move = False
            else:
                move = True    
        if key == glfw.KEY_UP:
            global it
            if it:
                glDisable(GL_TEXTURE_2D)
            else:
                glEnable(GL_TEXTURE_2D)    
            it = not it      
                      

def main():
    if not glfw.init():
        return
    window = glfw.create_window(900, 900, "l3", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    glGenTextures(1, texture)
    glBindTexture(GL_TEXTURE_2D, texture)
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 96, 96, 0, GL_RGB, GL_UNSIGNED_BYTE, image)
    glGenerateMipmap(GL_TEXTURE_2D)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_TEXTURE_COORD_ARRAY)
    light_display_list()
    display_list()
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()

generate()
main()