
from kivy.uix.widget import Widget
from kivy.graphics import RenderContext, Rectangle, BindTexture
from kivy.clock import Clock
from kivy.core.window import Window

# --- CONFIGURATION (Match your Kotlin values here) ---
# 16.dp -> approx 0.05 in UV space
# 32.dp -> approx 0.10 in UV space
REFRACTION_AMOUNT = 0.10
REFRACTION_HEIGHT = 0.15

with open('liquid.glsl', 'r') as f:
    SHADER_SOURCE = f.read()


class LiquidGlassLayer(Widget):
    def __init__(self, bg_source, **kwargs):
        super().__init__(**kwargs)
        self.bg_source = bg_source

        self.canvas = RenderContext(use_parent_projection=True, use_parent_modelview=True)
        self.canvas.shader.fs = SHADER_SOURCE

        # Initialize Uniforms
        self.canvas['texture1'] = 1
        self.canvas['u_refractionAmount'] = float(REFRACTION_AMOUNT)
        self.canvas['u_refractionHeight'] = float(REFRACTION_HEIGHT)

        with self.canvas:
            self.bg_bind = BindTexture(index=1)
            self.rect = Rectangle(pos=self.pos, size=self.size)

        Clock.schedule_interval(self.update_glsl, 1 / 60.0)

    def update_glsl(self, dt):
        self.rect.pos = self.pos
        self.rect.size = self.size

        self.canvas['time'] = Clock.get_boottime()
        self.canvas['resolution'] = [float(x) for x in self.size]

        mouse_pos = Window.mouse_pos
        self.canvas['mouse'] = [float(mouse_pos[0]), float(mouse_pos[1])]

        # Pass the background texture
        if self.bg_source.texture:
            self.bg_bind.texture = self.bg_source.texture

