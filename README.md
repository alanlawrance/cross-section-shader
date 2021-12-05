# cross-section-shader
Cross Section shader for Universal Render Pipeline in Unity3D

The high level approach is to render a mesh as two sided, and have backfacing triangles write 255 to the stencil buffer.
The cutting planes then use the stencil buffer to only render over the backfaces.

The shaders are provided as Shader Graph, but you have to manually add the Stencil operations by hand to the generated .shader code.

Follow @AlanLawrance on Twitter for Unity related tips and info on future open source tools/code.
