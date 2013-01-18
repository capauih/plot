package by.bsu.rfe.nosova.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFRichTextString;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import java.io.IOException;
import java.io.OutputStream;
import java.util.List;

import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.ss.usermodel.IndexedColors;

public class ExcelSheetWriter {
	
	private static final String BOOK_NAME = "dataSheet1"; 

	public static void writeExcelFile(List<String> headers, List<Double[]> data, OutputStream stream) {
		try {
			HSSFWorkbook sampleWorkbook = new HSSFWorkbook();
			HSSFSheet sampleDataSheet = sampleWorkbook.createSheet(BOOK_NAME);
			
			HSSFRow headerRow = sampleDataSheet.createRow(0);
			
			HSSFCell cell = null;
			HSSFCellStyle cellStyle = setHeaderStyle(sampleWorkbook);
			for(int i = 0; i<headers.size();i++){
				cell = headerRow.createCell(i);
				cell.setCellStyle(cellStyle);
				cell.setCellValue(new HSSFRichTextString(headers.get(i)));
			}
			
			HSSFRow dataRow = null;
			for(int i = 0;i<data.size();i++){
				
				dataRow = sampleDataSheet.createRow(i+1);
				for(int j=0;j<data.get(i).length;j++){
					cell = dataRow.createCell(j);
					cell.setCellValue(data.get(i)[j]);
				}
				
			}

			sampleWorkbook.write(stream);
		} catch (Exception ex) {
			ex.printStackTrace();
		} finally {
			try {
				if (stream != null) {
					stream.close();
				}
			} catch (IOException ex) {
				ex.printStackTrace();
			}
		}
	}

	private static HSSFCellStyle setHeaderStyle(HSSFWorkbook sampleWorkBook) {
		HSSFFont font = sampleWorkBook.createFont();
		font.setFontName(HSSFFont.FONT_ARIAL);
		font.setColor(IndexedColors.PLUM.getIndex());
		font.setBoldweight(HSSFFont.BOLDWEIGHT_BOLD);
		HSSFCellStyle cellStyle = sampleWorkBook.createCellStyle();
		cellStyle.setFont(font);
		return cellStyle;
	}
}
