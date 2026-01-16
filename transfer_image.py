
import os

def transfer_image():
    source_path = r"c:\Antigravity\daveweinstein1\old.resume.html"
    dest_path = r"c:\Antigravity\daveweinstein1\index.html"

    img_tag = ""
    with open(source_path, "r", encoding="utf-8") as f:
        for line in f:
            if 'src="data:image/png;base64,' in line:
                img_tag = line.strip()
                # Ensure we add the class if it's missing or replace it
                if 'class="profile-photo"' not in img_tag:
                     img_tag = img_tag.replace('>', ' class="profile-photo">')
                break
    
    if not img_tag:
        print("Error: Could not find image tag in source file.")
        return

    with open(dest_path, "r", encoding="utf-8") as f:
        dest_lines = f.readlines()

    new_lines = []
    inserted = False
    for line in dest_lines:
        if '<div class="name">Dave Weinstein</div>' in line and not inserted:
            new_lines.append('            ' + img_tag + '\n')
            new_lines.append(line)
            inserted = True
        else:
            new_lines.append(line)

    with open(dest_path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
    
    print("Successfully transferred image tag.")

if __name__ == "__main__":
    transfer_image()
