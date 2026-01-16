
import base64
import os

def update_profile_photo():
    image_path = r"C:/Users/dw/.gemini/antigravity/brain/87fab5cd-3670-47cd-b231-29f472a733b0/uploaded_image_1768214006491.jpg"
    html_path = r"c:\Antigravity\daveweinstein1\index.html"

    # 1. Read and encode the image
    try:
        with open(image_path, "rb") as img_file:
            b64_string = base64.b64encode(img_file.read()).decode('utf-8')
            # It's a JPG, so appropriate mime type
            img_src = f"data:image/jpeg;base64,{b64_string}"
            new_img_tag = f'<img src="{img_src}" alt="Dave Weinstein" class="profile-photo">'
    except FileNotFoundError:
        print(f"Error: Image file not found at {image_path}")
        return

    # 2. Read the HTML file
    try:
        with open(html_path, "r", encoding="utf-8") as html_file:
            lines = html_file.readlines()
    except FileNotFoundError:
        print(f"Error: HTML file not found at {html_path}")
        return

    # 3. Replace the image tag
    new_lines = []
    replaced = False
    for line in lines:
        # Look for the line containing the img tag we previously inserted (or the old one)
        if '<img src="data:image' in line and 'class="profile-photo"' in line:
             new_lines.append(f"            {new_img_tag}\n")
             replaced = True
        elif '<img src="data:image' in line and 'alt="Dave Weinstein"' in line:
             # Fallback matching just in case
             new_lines.append(f"            {new_img_tag}\n")
             replaced = True
        else:
            new_lines.append(line)

    if not replaced:
        # If we didn't find specific line, insert before Name div as fallback (handling previous script's logic)
        final_lines = []
        for line in new_lines: # iterating over the copy we just made which is effectively original lines if not replaced
             if '<div class="name">Dave Weinstein</div>' in line:
                 final_lines.append(f"            {new_img_tag}\n")
                 final_lines.append(line)
             else:
                 final_lines.append(line)
        new_lines = final_lines

    # 4. Write back
    with open(html_path, "w", encoding="utf-8") as html_file:
        html_file.writelines(new_lines)
    
    print("Successfully updated profile photo with new base64 image.")

if __name__ == "__main__":
    update_profile_photo()
