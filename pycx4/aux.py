
import os, os.path

def cxpath():
    path2cx = os.getenv('CXDIR')
    if path2cx is not None:
        return path2cx
    subdirs = ['/work', '/cx', '/control_system']
    home = os.getenv('HOME')
    for x in subdirs:
        path2cx = home + x
        if os.path.exists(path2cx + '/4cx'):
            return path2cx
    return None


if __name__ == '__main__':
    print(cxpath())