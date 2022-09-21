from curses import KEY_DOWN
from re import I, L
import time
import glfw
from OpenGL.GL import *
from math import *

def read_rows(path):
    image_file = open(path, "rb")
    # Blindly skip the BMP header.
    image_file.seek(54)

    # We need to read pixels in as rows to later swap the order
    # since BMP stores pixels starting at the bottom left.
    rows = []
    row = []
    pixel_index = 0

    while True:
        if pixel_index == 96:
            pixel_index = 0
            rows.insert(0, row)
            if len(row) != 96 * 3:
                raise Exception("Row length is not 1920*3 but " + str(len(row)) + " / 3.0 = " + str(len(row) / 3.0))
            row = []
        pixel_index += 1

        r_string = image_file.read(1)
        g_string = image_file.read(1)
        b_string = image_file.read(1)

        if len(r_string) == 0:
            # This is expected to happen when we've read everything.
            if len(rows) != 96:
                print ("Warning!!! Read to the end of the file at the correct sub-pixel (red) but we've not read 1080 rows!")
            break

        if len(g_string) == 0:
            print ("Warning!!! Got 0 length string for green. Breaking.")
            break

        if len(b_string) == 0:
            print ("Warning!!! Got 0 length string for blue. Breaking.")
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
    print ("Repacking pixels...")
    sub_pixels = []
    for row in rows:
        for sub_pixel in row:
            sub_pixels.append(sub_pixel)

    diff = len(sub_pixels) - 96 * 96 * 3
    print ("Packed", len(sub_pixels), "sub-pixels.")
    if diff != 0:
        print ("Error! Number of sub-pixels packed does not match 1920*1080: (" + str(len(sub_pixels)) + " - 1920 * 1080 * 3 = " + str(diff) +").")

    return sub_pixels

#rows = read_rows("zebrano02.bmp")
#rows = read_rows("zeder.bmp")
rows = read_rows("ziricote.bmp")
#rows = read_rows("rosenholz.bmp")
#rows = read_rows("thuya-maser.bmp")
image = repack_sub_pixels(rows)

sc = 0.1
an1 = 0
an2 = 0
an3 = 0

v0 = 0
g = 0.00049
surface = -3.3
h0 = 0

light = False
move = False
it = False
texture = 0

def el_para(x, y, z, angle1, angle2, angle3, s):
    p = 0
    glScalef(s, s, s)
    glTranslatef(x, y, z)
    glRotatef(angle1, 1, 0, 0)
    glRotatef(angle2, 0, 1, 0)
    glRotatef(angle3, 0, 0, 1)
    t = 0
    while t < 10 * pi:
        glBegin(GL_LINE_STRIP)
        if it:
            glColor3f(1, 1, 1)
            if p == 0:
                glTexCoord2f(0, 0)
                p += 1
            elif p == 1:
                glTexCoord2f(0, 1)
                p += 1
            elif p == 2:
                glTexCoord2f(1, 1)
                p += 1
            elif p == 3:
                glTexCoord2f(1, 0)
                p = 0     
        else:
            glColor3f(0.6, 0, 1)
                 
        k = -1.4
        while k < 1.5:
            x = k*cos(t)
            z = k*sin(t)
            y = k*k
            glVertex3f(x,y,z)
            k += 0.1
        glEnd()    
        t += 0.1


def light_on():
    if it:
        material_diffuse = [1, 1.0, 1.0, 1.0] 
    else:
        material_diffuse = [0.6, 0.0, 1.0, 1.0] 
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, material_diffuse)
    light3_diffuse = [1, 1, 1]
    light3_position = [0.0, 0.0, 1.0, 1.0]
    light3_spot_direction = [0.0, 0.0, -1.0]
    glEnable(GL_LIGHT0)
    glLightfv(GL_LIGHT0, GL_DIFFUSE, light3_diffuse)
    glLightfv(GL_LIGHT0, GL_POSITION, light3_position)
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, 10)
    glLightfv(GL_LIGHT0, GL_SPOT_DIRECTION, light3_spot_direction)

def display(window):
    start = time.monotonic()
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    if light:
        light_on()

    glMatrixMode(GL_MODELVIEW)

    glLoadIdentity()
    if not move:
        glPushMatrix()
        el_para(0, 0, 0,  an1,an2,an3, 0.3)
        glPopMatrix()
    if move:
        global h0
        global v0
        glPushMatrix()
        el_para(0, h0, 0,  an1,an2,an3, 0.3)
        h0 += v0
        v0 -= g
        if h0 <= surface or h0 > 0:
            v0 = -1 * v0
        glPopMatrix()  

    glfw.swap_buffers(window)
    glfw.poll_events()
    end = time.monotonic()
    print(end - start)



def key_callback(window, key, scancode, action, mods):
    global an1
    global an2
    global an3
    global sc
    global light
    global move
    if action == glfw.PRESS:
        if key ==  glfw.KEY_UP:
            sc += 0.01
        if key ==  glfw.KEY_DOWN:
            sc -= 0.01
        if key == 49:
            an1 += 5
        if key == 50:
            an1 -=5
        if key == 51:
            an2 += 5
        if key == 52:
            an2 -=5
        if key == 53:
            an3 += 5
        if key == 54:
            an3 -= 5   
        if key == glfw.KEY_ENTER:
            if light:
                light = False
                glDisable(GL_LIGHTING)
            else:
                glEnable(GL_LIGHTING)
                glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE)
                glEnable(GL_NORMALIZE)
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
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


main()