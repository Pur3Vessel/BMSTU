import glfw
from OpenGL.GL import *
from math import *
sc = 0.2
an1 = 0
an2 = 0
an3 = 0
def cube(x, y, z, angle1, angle2, angle3, s):
    glScalef(s, s, s)
    glTranslatef(x, y, z)
    glRotatef(angle1, 1, 0, 0)
    glRotatef(angle2, 0, 1, 0)
    glRotatef(angle3, 0, 0, 1)
    glRotatef(0.0, 1.0, 0.0, 0.0)
    glRotatef(0.0, 0.0, 1.0, 0.0)
    glRotatef(0.0, 0.0, 0.0, 1.0)

    glBegin(GL_POLYGON)
    glColor3f(0.5, 0, 0.5)
    glVertex3f(0.5, -0.5, 0.5)
    glVertex3f(0.5, 0.5, 0.5)
    glVertex3f(-0.5, 0.5, 0.5)
    glVertex3f(-0.5, -0.5, 0.5)
    glEnd()

    glBegin(GL_POLYGON)
    glColor3f(0, 0.3, 0.3)
    glVertex3f(0.5, -0.5, -0.5)
    glVertex3f(0.5, 0.5, -0.5)
    glVertex3f(-0.5, 0.5, -0.5)
    glVertex3f(-0.5, -0.5, -0.5)
    glEnd()

    glBegin(GL_POLYGON)
    glColor3f(1.0, 0.0, 1.0)
    glVertex3f(0.5, -0.5, -0.5)
    glVertex3f(0.5, 0.5, -0.5)
    glVertex3f(0.5, 0.5, 0.5)
    glVertex3f(0.5, -0.5, 0.5)
    glEnd()

    glBegin(GL_POLYGON)
    glColor3f(0.0, 1.0, 0.0)
    glVertex3f(-0.5, -0.5, 0.5)
    glVertex3f(-0.5, 0.5, 0.5)
    glVertex3f(-0.5, 0.5, -0.5)
    glVertex3f(-0.5, -0.5, -0.5)
    glEnd()

    glBegin(GL_POLYGON)
    glColor3f(0.0, 0.0, 1.0)
    glVertex3f(0.5, 0.5, 0.5)
    glVertex3f(0.5, 0.5, -0.5)
    glVertex3f(-0.5, 0.5, -0.5)
    glVertex3f(-0.5, 0.5, 0.5)
    glEnd()

    glBegin(GL_POLYGON)
    glColor3f(1.0, 0.0, 0.0)
    glVertex3f(0.5, -0.5, -0.5)
    glVertex3f(0.5, -0.5, 0.5)
    glVertex3f(-0.5, -0.5, 0.5)
    glVertex3f(-0.5, -0.5, -0.5)
    glEnd()

def up():
    m = [1, 0, 0, 0,
    0,1,0,0,
    0,0,1,0,
    0,0,0,1]
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glMultMatrixd(m)
    glMatrixMode(GL_MODELVIEW)
    glPushMatrix()
    cube(0, -3, 1, an1, an2, an3, sc)
    glPopMatrix()
    
def side():
    m = [0, 0, -1, 0,
    0,1,0,0,
    -1,0,0,0,
    0,0,0,1]
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glMultMatrixd(m)
    glMatrixMode(GL_MODELVIEW)
    glPushMatrix()
    cube(0, 3, 1, an1, an2, an3, sc)
    glPopMatrix()

def down():
    m = [1, 0, 0, 0,
    0,0,-1,0,
    0,-1,0,0,
    0,0,0,1]
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    glMultMatrixd(m)
    glMatrixMode(GL_MODELVIEW)
    glPushMatrix()
    cube(-3, 0, 1, an1, an2, an3, sc)
    glPopMatrix()

def display(window):
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT )
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity()
    q = 29.52
    psi = -26.23
    m = [cos(q), -cos(psi)*sin(q), sin(q) * sin(psi), 0,
         -sin(q), -cos(psi)*cos(q), sin(psi)*cos(q), 0,
         0, sin(q), cos(psi), 0,
         0, 0, 0, 1]
    glMultMatrixd(m)
    glEnable(GL_DEPTH_TEST)
    glMatrixMode(GL_MODELVIEW)

    glLoadIdentity()
    
    glPushMatrix()
    cube(3, 0, 1, 0,0,0, 0.2)
    glPopMatrix()
    up()
    side()
    down()

    glfw.swap_buffers(window)
    glfw.poll_events()



def key_callback(window, key, scancode, action, mods):
    global an1
    global an2
    global an3
    global sc
    if action == glfw.PRESS:
        if key ==  glfw.KEY_UP:
            sc += 0.01
        if key ==  glfw.KEY_DOWN:
            sc -= 0.01
        if key == 49:
            an1 += 1
        if key == 50:
            an1 -=1
        if key == 51:
            an2 += 1
        if key == 52:
            an2 -=1
        if key == 53:
            an3 += 1
        if key == 54:
            an3 -=1    
        if key == 81:
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)   
        if key == 87:
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)            
                      

def main():
    if not glfw.init():
        return
    window = glfw.create_window(900, 900, "cube", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glClearColor(1.0, 1.0, 1.0, 1.0)
    
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


main()