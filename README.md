# PYTHON LIQUID GLASS SHADER

A Liquid Glass Shader for python

# How To Use?

Move the liquidglass.py and liquid.glsl to the root of your project. You will also need the requirements.txt

Go to where the requirements.txt is located and run the following command:

```bash

pip install -r requirements.txt

```
You are going to need a background ( jpg file only )

# Sample Code

```python

from kivy.app import App
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.image import Image

from liquidglass import LiquidGlassLayer

class LiquidApp(App):
    def build(self):
        root = FloatLayout()

        # 1. Add a background image (this is what will be refracted)
        # Use a high-contrast image for the best effect
        bg = Image(
            source='bg.jpg',
            allow_stretch=True,
            keep_ratio=False,
            size_hint=(1, 1)
        )
        root.add_widget(bg)

        # 2. Add the Liquid Glass Layer
        # We pass the 'bg' widget so the shader can access its texture
        glass_effect = LiquidGlassLayer(bg_source=bg, size_hint=(1, 1))
        root.add_widget(glass_effect)

        return root

if __name__ == '__main__':
    LiquidApp().run()

```
