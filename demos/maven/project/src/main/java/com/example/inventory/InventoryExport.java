package com.example.inventory;

import com.google.common.io.ByteSource;
import com.google.common.io.FileBackedOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.util.List;

/** Writes the items as CSV. An export larger than the memory limit goes to a temporary file. */
public final class InventoryExport {

    private final int memoryLimitInBytes;

    public InventoryExport(int memoryLimitInBytes) {
        this.memoryLimitInBytes = memoryLimitInBytes;
    }

    public ByteSource exportAsCsv(List<Item> items) throws IOException {
        FileBackedOutputStream buffer = new FileBackedOutputStream(memoryLimitInBytes, true);
        try (Writer writer = new OutputStreamWriter(buffer, StandardCharsets.UTF_8)) {
            writer.write("name,quantity\n");
            for (Item item : items) {
                writer.write(item.name() + "," + item.quantity() + "\n");
            }
        }
        return buffer.asByteSource();
    }
}
