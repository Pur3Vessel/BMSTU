import glfw
from OpenGL.GL import *
shift = 0
shiftDelta = 0
jumpShift = 0
jumpShiftDelta = 0.02
delta = 0
angle = -90
posx = 0.0
posy = 0.0
size = 0.0
mode = True
jumpMode = 0
def display(window):
    global angle
    global mode
    global shift
    global jumpMode
    global jumpShift
    glClear(GL_COLOR_BUFFER_BIT)
    glLoadIdentity()
    glClearColor(1.0, 1.0, 1.0, 1.0)
    glPushMatrix()
    glTranslatef(shift, jumpShift, 0)
    glRotatef(angle, 0, 0, 1)
    glBegin(GL_TRIANGLE_STRIP)
    glColor3f(0.1, 0.1, 0.1)
    glVertex2f(posx + size + 0.5, posy + size + 0.5)
    glColor3f(0.35, 0.0, 0.89)
    glVertex2f(posx - size + -0.5, posy + size + 0.5)
    glColor3f(0.0, 1.0, 1.0)
    glVertex2f(posx - size + -0.5, posy - size + -0.5)
    glColor3f(0.78, 0.23, 1.0)
    glVertex2f(posx + size + 0.5, posy - size + -0.5)
    glEnd()
    glPopMatrix()

    if mode:
        angle += delta
    else:
        angle -= delta
    if angle >= -65:
        mode = False
    if angle <= -115:
        mode = True
    if jumpMode == 1:
        jumpShift += jumpShiftDelta
    if jumpMode == 2:
        jumpShift -= jumpShiftDelta
    if jumpShift < 0 and jumpMode == 2:
        jumpMode = 0
    if jumpShift >= 0.3:
        jumpMode = 2
    shift += shiftDelta
    glfw.swap_buffers(window)
    glfw.poll_events()

def scroll_callback(window, xoffset, yoffset):
    global size
    if (xoffset > 0):
        size -= yoffset/10
    else:
        size += yoffset/10
def key_callback(window, key, scancode, action, mods):
    global shiftDelta
    global shift
    global delta
    global angle
    global jumpMode
    if action == glfw.PRESS:
        if key == glfw.KEY_RIGHT:
            shiftDelta = 0.01
            delta = 1.3
        if key == glfw.KEY_LEFT:
            shiftDelta = -0.01
            delta = 1.3
        if key == glfw.KEY_DOWN:
            shiftDelta = 0
            delta = 0
            angle = -90
        if key == glfw.KEY_UP:
            if jumpMode == 0:
                jumpMode = 1

def main():
    if not glfw.init():
        return
    window = glfw.create_window(1000, 1000, "humanLegs", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    glfw.set_key_callback(window, key_callback)
    glfw.set_scroll_callback(window, scroll_callback)
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


main()