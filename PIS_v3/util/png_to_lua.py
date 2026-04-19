from PIL import Image


def png_to_lua_table_int(image_path):
    # Load the image and ensure it's in RGBA format
    img = Image.open(image_path).convert('RGBA')

    # Resize to 12x12
    img = img.resize((12, 12))

    pixels = img.load()
    width, height = img.size

    lua_output = "local image_data = {\n"

    for y in range(height):
        row = "    {"
        for x in range(width):
            r, g, b, a = pixels[x, y]

            if a == 0:
                # Using false for transparent as requested
                cell = "false"
            else:
                # Format as 0xRRGGBB integer literal
                hex_int = (r << 16) | (g << 8) | b
                cell = f"0x{hex_int:06X}"

            row += cell + (", " if x < width - 1 else "")
        lua_output += row + "},\n"

    lua_output += "}"
    print(lua_output)


if __name__ == "__main__":
    import sys

    png_to_lua_table_int(sys.argv[1])
