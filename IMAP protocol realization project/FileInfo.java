public class FileInfo {
    public String name;
    public byte[] data;

    public FileInfo(String name, byte[] data) {
        this.name = name;
        this.data = data;
    }
    
    public String getFileName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public byte[] getData() {
        return data;
    }

    public void setData(byte[] data) {
        this.data = data;
    }
}
