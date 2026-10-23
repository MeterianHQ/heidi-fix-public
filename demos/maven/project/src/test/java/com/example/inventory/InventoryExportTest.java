package com.example.inventory;

import static org.junit.jupiter.api.Assertions.assertEquals;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;
import org.junit.jupiter.api.Test;

class InventoryExportTest {

    private static final List<Item> ITEMS = List.of(new Item("bolt", 12), new Item("nut", 40));

    @Test
    void exportsTheItemsAsCsvInMemory() throws IOException {
        String csv = new InventoryExport(1024).exportAsCsv(ITEMS).asCharSource(StandardCharsets.UTF_8).read();

        assertEquals("name,quantity\nbolt,12\nnut,40\n", csv);
    }

    @Test
    void exportsALargeExportThroughATemporaryFile() throws IOException {
        String csv = new InventoryExport(8).exportAsCsv(ITEMS).asCharSource(StandardCharsets.UTF_8).read();

        assertEquals("name,quantity\nbolt,12\nnut,40\n", csv);
    }
}
