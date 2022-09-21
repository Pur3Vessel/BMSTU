import glfw
import glm
from OpenGL.GL import *
from math import *
pointdata = []
pointcolor = []
n = 0

v0 = 0
g = 0.00099
surface = -3.3
h0 = 0

def create_shader(shader_type, source):
    shader = glCreateShader(shader_type)
    glShaderSource(shader, source)
    glCompileShader(shader)
    return shader

def create_figure(x, y, z):
    global pointdata
    global pointcolor
    global n
    pointdata = []
    pointcolor = []
    n = 0
    color = [1.0, 1.0, 1.0]
    t = 0
    while t < 2.5  * pi:              
        k = -1.4
        while k < 1.5:
            x = k*cos(t)
            z = k*sin(t)
            y = k*k
            newPoint = [x, y, z]
            pointdata.append(newPoint)
            pointcolor.append(color)
            n += 1
            k += 0.1 
        t += 0.1
def display(window):
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glEnableClientState(GL_VERTEX_ARRAY)
    glEnableClientState(GL_COLOR_ARRAY)
    glVertexPointer(3, GL_FLOAT, 0, pointdata)
    glColorPointer(3, GL_FLOAT, 0, pointcolor)
    glDrawArrays(GL_LINE_STRIP, 0, n)
    glDisableClientState(GL_VERTEX_ARRAY) 
    glDisableClientState(GL_COLOR_ARRAY) 
    global v0
    global h0
    glTranslatef(0, v0, 0)
    h0 += v0
    v0 -= g
    if h0 <= surface:
        v0 = -1 * v0
    glfw.swap_buffers(window)
    glfw.poll_events()
    



#def key_callback(window, key, scancode, action, mods):
  
                      

def main():
    if not glfw.init():
        return
    window = glfw.create_window(900, 900, "l3", None, None)
    if not window:
        glfw.terminate()
        return
    glfw.make_context_current(window)
    #glfw.set_key_callback(window, key_callback)
    glClearColor(0.0, 0.0, 0.0, 1.0)
    vertex = create_shader(GL_VERTEX_SHADER, """
                varying vec4 vertex_color;
                void main(){
                    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
                    vertex_color = gl_Color;
                }""")
    fragment = create_shader(GL_FRAGMENT_SHADER, """
            varying vec4 vertex_color;
            void main() {
                gl_FragColor = vertex_color;
            }""")
    program = glCreateProgram()
    glAttachShader(program, vertex)
    glAttachShader(program, fragment)
    glLinkProgram(program)
    glScalef(0.3, 0.3, 0.3)
    create_figure(0, -3, 0)
    glUseProgram(program)
    while not glfw.window_should_close(window):
        display(window)
    glfw.destroy_window(window)
    glfw.terminate()


main()