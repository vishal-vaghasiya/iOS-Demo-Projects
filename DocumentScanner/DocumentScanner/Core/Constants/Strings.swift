//
//  Strings.swift
//  DocumentScanner
//
//  Created by Nexios Technologies LLP on 03/06/26.
//

internal import Foundation

struct Strings {
    struct General {
        static let cancel = NSLocalizedString("general_cancel", value: "Cancel", comment: "Cancel button")
        static let save = NSLocalizedString("general_save", value: "Save", comment: "Save button")
        static let done = NSLocalizedString("general_done", value: "Done", comment: "Done button")
        static let delete = NSLocalizedString("general_delete", value: "Delete", comment: "Delete button")
        static let rename = NSLocalizedString("general_rename", value: "Rename", comment: "Rename button")
        static let share = NSLocalizedString("general_share", value: "Share", comment: "Share button")
        static let favorite = NSLocalizedString("general_favorite", value: "Favorite", comment: "Favorite button")
        static let unfavorite = NSLocalizedString("general_unfavorite", value: "Unfavorite", comment: "Unfavorite button")
        static let error = NSLocalizedString("general_error", value: "Error", comment: "Error header")
        static let success = NSLocalizedString("general_success", value: "Success", comment: "Success header")
        static let loading = NSLocalizedString("general_loading", value: "Loading...", comment: "Loading label")
        static let options = NSLocalizedString("general_options", value: "Options", comment: "Options header")
    }

    struct Dashboard {
        static let title = NSLocalizedString("dashboard_title", value: "Document Scanner", comment: "Dashboard screen title")
        static let pdfSection = NSLocalizedString("dashboard_pdf_section", value: "PDF Tools", comment: "PDF Tools section")
        static let pdfAISection = NSLocalizedString("dashboard_pdf_ai_section", value: "PDF AI", comment: "PDF AI section")
        static let pdfAnnotationSection = NSLocalizedString("dashboard_pdf_annotation_section", value: "PDF Annotation", comment: "PDF annotation section")
        static let pdfOrganizationSection = NSLocalizedString("dashboard_pdf_organization_section", value: "PDF Organization", comment: "PDF organization section")
        static let watermarkSection = NSLocalizedString("dashboard_watermark_section", value: "Watermark Tools", comment: "Watermark tools section")
        static let scannerSection = NSLocalizedString("dashboard_scanner_section", value: "Scanner", comment: "Scanner tools section")
        static let ocrSection = NSLocalizedString("dashboard_ocr_section", value: "OCR Reader", comment: "OCR tools section")
        static let imageSection = NSLocalizedString("dashboard_image_section", value: "Image Tools", comment: "Image tools section")
        static let additionalConversionsSection = NSLocalizedString("dashboard_additional_conversions_section", value: "Additional Conversions", comment: "Additional conversions section")
        static let metadataSection = NSLocalizedString("dashboard_metadata_section", value: "Metadata Tools", comment: "Metadata tools section")
        static let utilitiesSection = NSLocalizedString("dashboard_utilities_section", value: "Utilities", comment: "Utilities section")
        static let exportSection = NSLocalizedString("dashboard_export_section", value: "Export", comment: "Export tools section")
        static let recentFiles = NSLocalizedString("dashboard_recent_files", value: "Recent Files", comment: "Recent files section header")
        static let viewAll = NSLocalizedString("dashboard_view_all", value: "View All", comment: "View all files button")
        static let noRecentFiles = NSLocalizedString("dashboard_no_recent_files", value: "No recent files. Try performing an action above!", comment: "No recent files message")

        // Tool Titles & Descriptions
        static let createPdf = NSLocalizedString("tool_create_pdf", value: "Create PDF", comment: "Create PDF tool name")
        static let createPdfDesc = NSLocalizedString("tool_create_pdf_desc", value: "Convert photos or text to PDF files", comment: "Create PDF description")

        static let mergePdf = NSLocalizedString("tool_merge_pdf", value: "Merge PDF", comment: "Merge PDF tool name")
        static let mergePdfDesc = NSLocalizedString("tool_merge_pdf_desc", value: "Combine multiple PDFs into one", comment: "Merge PDF description")

        static let splitPdf = NSLocalizedString("tool_split_pdf", value: "Split PDF", comment: "Split PDF tool name")
        static let splitPdfDesc = NSLocalizedString("tool_split_pdf_desc", value: "Extract pages or split a PDF file", comment: "Split PDF description")

        static let compressPdf = NSLocalizedString("tool_compress_pdf", value: "Compress PDF", comment: "Compress PDF tool name")
        static let compressPdfDesc = NSLocalizedString("tool_compress_pdf_desc", value: "Optimize and reduce PDF size", comment: "Compress PDF description")

        static let pdfSecurity = NSLocalizedString("tool_pdf_security", value: "PDF Security", comment: "PDF Security tool name")
        static let pdfSecurityDesc = NSLocalizedString("tool_pdf_security_desc", value: "Protect or unlock PDFs with a password", comment: "PDF Security description")

        static let editPdf = NSLocalizedString("tool_edit_pdf", value: "Edit PDF", comment: "Edit PDF tool name")
        static let editPdfDesc = NSLocalizedString("tool_edit_pdf_desc", value: "Use all PDF editing tools in one place", comment: "Edit PDF description")
        static let addSignature = NSLocalizedString("tool_add_signature", value: "Add Signature", comment: "Add Signature tool name")
        static let addSignatureDesc = NSLocalizedString("tool_add_signature_desc", value: "Sign a PDF with text or drawing", comment: "Add Signature description")
        static let addPageNumbers = NSLocalizedString("tool_add_page_numbers", value: "Add Page Numbers", comment: "Add Page Numbers tool name")
        static let addPageNumbersDesc = NSLocalizedString("tool_add_page_numbers_desc", value: "Number every page in a PDF", comment: "Add Page Numbers description")
        static let annotatePdf = NSLocalizedString("tool_annotate_pdf", value: "PDF Annotation", comment: "PDF Annotation tool name")
        static let annotatePdfDesc = NSLocalizedString("tool_annotate_pdf_desc", value: "Highlight, underline, draw, and add notes", comment: "PDF Annotation description")
        static let pdfSummary = NSLocalizedString("tool_pdf_summary", value: "PDF Summary", comment: "PDF Summary tool name")
        static let pdfSummaryDesc = NSLocalizedString("tool_pdf_summary_desc", value: "Create a concise text summary", comment: "PDF Summary description")
        static let extractKeyPoints = NSLocalizedString("tool_extract_key_points", value: "Extract Key Points", comment: "Extract Key Points tool name")
        static let extractKeyPointsDesc = NSLocalizedString("tool_extract_key_points_desc", value: "Pull out important PDF points", comment: "Extract Key Points description")
        static let generateNotes = NSLocalizedString("tool_generate_notes", value: "Generate Notes", comment: "Generate Notes tool name")
        static let generateNotesDesc = NSLocalizedString("tool_generate_notes_desc", value: "Turn PDF content into study notes", comment: "Generate Notes description")
        static let questionAnswering = NSLocalizedString("tool_question_answering", value: "Question Answering", comment: "Question Answering tool name")
        static let questionAnsweringDesc = NSLocalizedString("tool_question_answering_desc", value: "Ask questions about PDF text", comment: "Question Answering description")
        static let highlightText = NSLocalizedString("tool_highlight_text", value: "Highlight Text", comment: "Highlight Text tool name")
        static let highlightTextDesc = NSLocalizedString("tool_highlight_text_desc", value: "Mark important PDF text", comment: "Highlight Text description")
        static let underlineText = NSLocalizedString("tool_underline_text", value: "Underline Text", comment: "Underline Text tool name")
        static let underlineTextDesc = NSLocalizedString("tool_underline_text_desc", value: "Underline selected PDF text", comment: "Underline Text description")
        static let strikeThroughText = NSLocalizedString("tool_strike_through_text", value: "Strike-through Text", comment: "Strike-through Text tool name")
        static let strikeThroughTextDesc = NSLocalizedString("tool_strike_through_text_desc", value: "Strike out selected PDF text", comment: "Strike-through Text description")
        static let drawOnPDF = NSLocalizedString("tool_draw_on_pdf", value: "Draw on PDF", comment: "Draw on PDF tool name")
        static let drawOnPDFDesc = NSLocalizedString("tool_draw_on_pdf_desc", value: "Freehand draw on PDF pages", comment: "Draw on PDF description")
        static let pdfNotes = NSLocalizedString("tool_pdf_notes", value: "Notes", comment: "PDF Notes tool name")
        static let pdfNotesDesc = NSLocalizedString("tool_pdf_notes_desc", value: "Place notes on PDF pages", comment: "PDF Notes description")
        static let duplicatePages = NSLocalizedString("tool_duplicate_pages", value: "Duplicate Pages", comment: "Duplicate Pages tool name")
        static let duplicatePagesDesc = NSLocalizedString("tool_duplicate_pages_desc", value: "Copy selected pages in place", comment: "Duplicate Pages description")
        static let cropPdf = NSLocalizedString("tool_crop_pdf", value: "Crop PDF", comment: "Crop PDF tool name")
        static let cropPdfDesc = NSLocalizedString("tool_crop_pdf_desc", value: "Trim page margins across a PDF", comment: "Crop PDF description")
        static let reversePages = NSLocalizedString("tool_reverse_pages", value: "Reverse PDF Pages", comment: "Reverse PDF Pages tool name")
        static let reversePagesDesc = NSLocalizedString("tool_reverse_pages_desc", value: "Flip the document page order", comment: "Reverse PDF Pages description")
        static let pdfToLongImage = NSLocalizedString("tool_pdf_to_long_image", value: "PDF to Long Image", comment: "PDF to Long Image tool name")
        static let pdfToLongImageDesc = NSLocalizedString("tool_pdf_to_long_image_desc", value: "Stack pages into one JPG image", comment: "PDF to Long Image description")

        static let organizePdf = NSLocalizedString("tool_organize_pdf", value: "Organize PDF", comment: "Organize PDF tool name")
        static let organizePdfDesc = NSLocalizedString("tool_organize_pdf_desc", value: "Extract, delete, rearrange, or rotate pages", comment: "Organize PDF description")
        static let extractPages = NSLocalizedString("tool_extract_pages", value: "Extract Pages", comment: "Extract pages tool name")
        static let extractPagesDesc = NSLocalizedString("tool_extract_pages_desc", value: "Save selected pages as a new PDF", comment: "Extract pages description")
        static let deletePages = NSLocalizedString("tool_delete_pages", value: "Delete Pages", comment: "Delete pages tool name")
        static let deletePagesDesc = NSLocalizedString("tool_delete_pages_desc", value: "Remove selected pages from a PDF", comment: "Delete pages description")
        static let rearrangePages = NSLocalizedString("tool_rearrange_pages", value: "Rearrange Pages", comment: "Rearrange pages tool name")
        static let rearrangePagesDesc = NSLocalizedString("tool_rearrange_pages_desc", value: "Drag pages into a new order", comment: "Rearrange pages description")
        static let rotatePages = NSLocalizedString("tool_rotate_pages", value: "Rotate Pages", comment: "Rotate pages tool name")
        static let rotatePagesDesc = NSLocalizedString("tool_rotate_pages_desc", value: "Rotate selected PDF pages", comment: "Rotate pages description")
        static let addTextWatermark = NSLocalizedString("tool_add_text_watermark", value: "Add Text Watermark", comment: "Add Text Watermark tool name")
        static let addTextWatermarkDesc = NSLocalizedString("tool_add_text_watermark_desc", value: "Stamp repeated text across PDF pages", comment: "Add Text Watermark description")
        static let addLogoWatermark = NSLocalizedString("tool_add_logo_watermark", value: "Add Logo Watermark", comment: "Add Logo Watermark tool name")
        static let addLogoWatermarkDesc = NSLocalizedString("tool_add_logo_watermark_desc", value: "Place a logo watermark on PDF pages", comment: "Add Logo Watermark description")

        static let scanDoc = NSLocalizedString("tool_scan_doc", value: "Scan Document", comment: "Scan Document tool name")
        static let scanDocDesc = NSLocalizedString("tool_scan_doc_desc", value: "Scan papers and documents dynamically", comment: "Scan Document description")

        static let scanId = NSLocalizedString("tool_scan_id", value: "Scan ID Card", comment: "Scan ID Card tool name")
        static let scanIdDesc = NSLocalizedString("tool_scan_id_desc", value: "Capture front/back of identity cards", comment: "Scan ID Card description")

        static let scanPassport = NSLocalizedString("tool_scan_passport", value: "Scan Passport", comment: "Scan Passport tool name")
        static let scanPassportDesc = NSLocalizedString("tool_scan_passport_desc", value: "Scan official passports with VisionKit", comment: "Scan Passport description")

        static let scanReceipt = NSLocalizedString("tool_scan_receipt", value: "Receipt Scanner", comment: "Receipt Scanner tool name")
        static let scanReceiptDesc = NSLocalizedString("tool_scan_receipt_desc", value: "Capture and save receipts as PDF", comment: "Receipt Scanner description")

        static let scanBusinessCard = NSLocalizedString("tool_scan_business_card", value: "Business Card Scanner", comment: "Business Card Scanner tool name")
        static let scanBusinessCardDesc = NSLocalizedString("tool_scan_business_card_desc", value: "Capture contact cards as clean PDFs", comment: "Business Card Scanner description")

        static let zipExport = NSLocalizedString("tool_zip_export", value: "ZIP Export", comment: "ZIP Export tool name")
        static let zipExportDesc = NSLocalizedString("tool_zip_export_desc", value: "Package saved files into one ZIP", comment: "ZIP Export description")

        static let cloudBackup = NSLocalizedString("tool_cloud_backup", value: "Cloud Backup", comment: "Cloud Backup tool name")
        static let cloudBackupDesc = NSLocalizedString("tool_cloud_backup_desc", value: "Back up saved files for restore", comment: "Cloud Backup description")

        static let imageToText = NSLocalizedString("tool_image_to_text", value: "Image to Text", comment: "Image to Text tool name")
        static let imageToTextDesc = NSLocalizedString("tool_image_to_text_desc", value: "Extract text from selected images", comment: "Image to Text description")

        static let scanToText = NSLocalizedString("tool_scan_to_text", value: "Scan to Text", comment: "Scan to Text tool name")
        static let scanToTextDesc = NSLocalizedString("tool_scan_to_text_desc", value: "Scan paper documents straight to text", comment: "Scan to Text description")

        static let compressImage = NSLocalizedString("tool_compress_image", value: "Compress Image", comment: "Compress Image tool name")
        static let compressImageDesc = NSLocalizedString("tool_compress_image_desc", value: "Shrink file sizes of photos easily", comment: "Compress Image description")

        static let resizeImage = NSLocalizedString("tool_resize_image", value: "Resize Image", comment: "Resize Image tool name")
        static let resizeImageDesc = NSLocalizedString("tool_resize_image_desc", value: "Adjust resolution / custom sizes", comment: "Resize Image description")

        static let convertImage = NSLocalizedString("tool_convert_image", value: "Convert Image", comment: "Convert Image tool name")
        static let convertImageDesc = NSLocalizedString("tool_convert_image_desc", value: "HEIC, PNG, and JPEG formatting", comment: "Convert Image description")
        static let convertToHEIC = NSLocalizedString("tool_convert_to_heic", value: "Convert to HEIC", comment: "Convert to HEIC tool name")
        static let convertToHEICDesc = NSLocalizedString("tool_convert_to_heic_desc", value: "Create compact HEIC images", comment: "Convert to HEIC description")
        static let convertToWebP = NSLocalizedString("tool_convert_to_webp", value: "Convert to WEBP", comment: "Convert to WEBP tool name")
        static let convertToWebPDesc = NSLocalizedString("tool_convert_to_webp_desc", value: "Create WEBP images for sharing", comment: "Convert to WEBP description")
        static let convertToJPG = NSLocalizedString("tool_convert_to_jpg", value: "Convert to JPG", comment: "Convert to JPG tool name")
        static let convertToJPGDesc = NSLocalizedString("tool_convert_to_jpg_desc", value: "Create compatible JPG photos", comment: "Convert to JPG description")
        static let convertToPNG = NSLocalizedString("tool_convert_to_png", value: "Convert to PNG", comment: "Convert to PNG tool name")
        static let convertToPNGDesc = NSLocalizedString("tool_convert_to_png_desc", value: "Create lossless PNG images", comment: "Convert to PNG description")
        static let convertToGIF = NSLocalizedString("tool_convert_to_gif", value: "Convert to GIF", comment: "Convert to GIF tool name")
        static let convertToGIFDesc = NSLocalizedString("tool_convert_to_gif_desc", value: "Create an animated GIF", comment: "Convert to GIF description")
        static let webpToJpg = NSLocalizedString("tool_webp_to_jpg", value: "WEBP to JPG", comment: "WEBP to JPG tool name")
        static let webpToJpgDesc = NSLocalizedString("tool_webp_to_jpg_desc", value: "Convert WEBP files to JPG", comment: "WEBP to JPG description")
        static let webpToPng = NSLocalizedString("tool_webp_to_png", value: "WEBP to PNG", comment: "WEBP to PNG tool name")
        static let webpToPngDesc = NSLocalizedString("tool_webp_to_png_desc", value: "Convert WEBP files to PNG", comment: "WEBP to PNG description")
        static let jpgToWebp = NSLocalizedString("tool_jpg_to_webp", value: "JPG to WEBP", comment: "JPG to WEBP tool name")
        static let jpgToWebpDesc = NSLocalizedString("tool_jpg_to_webp_desc", value: "Convert JPG images to WEBP", comment: "JPG to WEBP description")
        static let pngToWebp = NSLocalizedString("tool_png_to_webp", value: "PNG to WEBP", comment: "PNG to WEBP tool name")
        static let pngToWebpDesc = NSLocalizedString("tool_png_to_webp_desc", value: "Convert PNG images to WEBP", comment: "PNG to WEBP description")
        static let gifToImages = NSLocalizedString("tool_gif_to_images", value: "GIF to Images", comment: "GIF to Images tool name")
        static let gifToImagesDesc = NSLocalizedString("tool_gif_to_images_desc", value: "Extract GIF frames as PNG", comment: "GIF to Images description")
        static let imagesToGif = NSLocalizedString("tool_images_to_gif", value: "Images to GIF", comment: "Images to GIF tool name")
        static let imagesToGifDesc = NSLocalizedString("tool_images_to_gif_desc", value: "Create an animated GIF", comment: "Images to GIF description")
        static let removeMetadata = NSLocalizedString("tool_remove_metadata", value: "Remove Metadata", comment: "Remove Metadata tool name")
        static let removeMetadataDesc = NSLocalizedString("tool_remove_metadata_desc", value: "Strip metadata from PDFs and images", comment: "Remove Metadata description")
        static let privacyCleaner = NSLocalizedString("tool_privacy_cleaner", value: "Privacy Cleaner", comment: "Privacy Cleaner tool name")
        static let privacyCleanerDesc = NSLocalizedString("tool_privacy_cleaner_desc", value: "Rebuild files to remove hidden private data", comment: "Privacy Cleaner description")
        static let convertLivePhotos = NSLocalizedString("tool_convert_live_photos", value: "Convert Live Photos", comment: "Convert Live Photos tool name")
        static let convertLivePhotosDesc = NSLocalizedString("tool_convert_live_photos_desc", value: "Save Live Photos as JPG images", comment: "Convert Live Photos description")
        static let extractVideoFrame = NSLocalizedString("tool_extract_video_frame", value: "Extract Frame from Video", comment: "Extract Frame from Video tool name")
        static let extractVideoFrameDesc = NSLocalizedString("tool_extract_video_frame_desc", value: "Save a selected video moment as JPG", comment: "Extract Frame from Video description")
    }

    struct PDFTools {
        static let createTitle = NSLocalizedString("pdf_create_title", value: "Create PDF", comment: "")
        static let mergeTitle = NSLocalizedString("pdf_merge_title", value: "Merge PDFs", comment: "")
        static let splitTitle = NSLocalizedString("pdf_split_title", value: "Split PDF", comment: "")
        static let compressTitle = NSLocalizedString("pdf_compress_title", value: "Compress PDF", comment: "")
        static let securityTitle = NSLocalizedString("pdf_security_title", value: "PDF Security", comment: "")

        static let fromImages = NSLocalizedString("pdf_from_images", value: "From Images", comment: "")
        static let fromText = NSLocalizedString("pdf_from_text", value: "From Text Input", comment: "")
        static let fromCamera = NSLocalizedString("pdf_from_camera", value: "From Camera Scan", comment: "")

        static let textPlaceholder = NSLocalizedString("pdf_text_placeholder", value: "Type your text here...", comment: "")
        static let enterFileName = NSLocalizedString("pdf_enter_file_name", value: "Enter file name", comment: "")
        static let generatePdf = NSLocalizedString("pdf_generate_btn", value: "Generate PDF", comment: "")

        static let selectPdfFiles = NSLocalizedString("pdf_select_files", value: "Select PDF Files", comment: "")
        static let dragToReorder = NSLocalizedString("pdf_drag_to_reorder", value: "Drag and drop items to reorder pages/files", comment: "")
        static let mergeBtn = NSLocalizedString("pdf_merge_btn", value: "Merge Files", comment: "")

        static let selectPagesToExtract = NSLocalizedString("pdf_select_pages", value: "Select pages to split / extract:", comment: "")
        static let splitBtn = NSLocalizedString("pdf_split_btn", value: "Extract Selected Pages", comment: "")

        static let compressionLevel = NSLocalizedString("pdf_compression_level", value: "Compression Level", comment: "")
        static let lowCompression = NSLocalizedString("pdf_low_compression", value: "Low (High Quality)", comment: "")
        static let mediumCompression = NSLocalizedString("pdf_medium_compression", value: "Medium (Balanced)", comment: "")
        static let highCompression = NSLocalizedString("pdf_high_compression", value: "High (Smallest Size)", comment: "")
        static let compressBtn = NSLocalizedString("pdf_compress_btn", value: "Compress PDF Now", comment: "")

        static let editTitle = NSLocalizedString("pdf_edit_title", value: "Edit PDF", comment: "")
        static let annotationTitle = NSLocalizedString("pdf_annotation_title", value: "PDF Annotation", comment: "")
        static let duplicatePagesTitle = NSLocalizedString("pdf_duplicate_pages_title", value: "Duplicate Pages", comment: "")
        static let cropPDFTitle = NSLocalizedString("pdf_crop_title", value: "Crop PDF", comment: "")
        static let reversePagesTitle = NSLocalizedString("pdf_reverse_pages_title", value: "Reverse PDF Pages", comment: "")
        static let pdfToLongImageTitle = NSLocalizedString("pdf_to_long_image_title", value: "PDF to Long Image", comment: "")
        static let addSignature = NSLocalizedString("pdf_add_signature", value: "Add Signature", comment: "")
        static let addText = NSLocalizedString("pdf_add_text", value: "Add Text", comment: "")
        static let addWatermark = NSLocalizedString("pdf_add_watermark", value: "Add Watermark", comment: "")
        static let addImage = NSLocalizedString("pdf_add_image", value: "Add Image", comment: "")
        static let editBtn = NSLocalizedString("pdf_edit_btn", value: "Save Edited PDF", comment: "")
        static let annotationBtn = NSLocalizedString("pdf_annotation_btn", value: "Save Annotated PDF", comment: "")
        static let duplicatePagesBtn = NSLocalizedString("pdf_duplicate_pages_btn", value: "Duplicate Selected Pages", comment: "")
        static let cropPDFBtn = NSLocalizedString("pdf_crop_btn", value: "Save Cropped PDF", comment: "")
        static let reversePagesBtn = NSLocalizedString("pdf_reverse_pages_btn", value: "Save Reversed PDF", comment: "")
        static let pdfToLongImageBtn = NSLocalizedString("pdf_to_long_image_btn", value: "Create Long Image", comment: "")

        static let organizeTitle = NSLocalizedString("pdf_organize_title", value: "Organize PDF", comment: "")
        static let organizeBtn = NSLocalizedString("pdf_organize_btn", value: "Save Organized PDF", comment: "")
        static let extractPagesTitle = NSLocalizedString("pdf_extract_pages_title", value: "Extract Pages", comment: "")
        static let deletePagesTitle = NSLocalizedString("pdf_delete_pages_title", value: "Delete Pages", comment: "")
        static let rearrangePagesTitle = NSLocalizedString("pdf_rearrange_pages_title", value: "Rearrange Pages", comment: "")
        static let rotatePagesTitle = NSLocalizedString("pdf_rotate_pages_title", value: "Rotate Pages", comment: "")
        static let deletePagesBtn = NSLocalizedString("pdf_delete_pages_btn", value: "Delete Selected Pages", comment: "")
        static let rearrangePagesBtn = NSLocalizedString("pdf_rearrange_pages_btn", value: "Save Rearranged PDF", comment: "")
        static let rotatePagesBtn = NSLocalizedString("pdf_rotate_pages_btn", value: "Save Rotated PDF", comment: "")
        static let rotateSelectedPages = NSLocalizedString("pdf_rotate_selected_pages", value: "Rotate Selected", comment: "")

        static let enterPassword = NSLocalizedString("pdf_enter_password", value: "Enter PDF Password", comment: "")
        static let confirmPassword = NSLocalizedString("pdf_confirm_password", value: "Confirm Password", comment: "")
        static let protectMode = NSLocalizedString("pdf_protect_mode", value: "Protect PDF", comment: "")
        static let removeProtectMode = NSLocalizedString("pdf_remove_protect_mode", value: "Remove Protect", comment: "")
        static let protectBtn = NSLocalizedString("pdf_protect_btn", value: "Apply Password Protection", comment: "")
        static let removeProtectBtn = NSLocalizedString("pdf_remove_protect_btn", value: "Remove Password Protection", comment: "")
        static let passwordEmptyError = NSLocalizedString("pdf_password_empty", value: "Password cannot be empty.", comment: "")
        static let passwordsDoNotMatch = NSLocalizedString("pdf_passwords_mismatch", value: "Passwords do not match.", comment: "")
    }

    struct WatermarkTools {
        static let textTitle = NSLocalizedString("watermark_text_title", value: "Add Text Watermark", comment: "")
        static let logoTitle = NSLocalizedString("watermark_logo_title", value: "Add Logo Watermark", comment: "")
        static let textDescription = NSLocalizedString("watermark_text_description", value: "Add a centered text watermark to every page of a PDF.", comment: "")
        static let logoDescription = NSLocalizedString("watermark_logo_description", value: "Add a logo image watermark to every page of a PDF.", comment: "")
        static let selectPDF = NSLocalizedString("watermark_select_pdf", value: "Select PDF to Watermark", comment: "")
        static let watermarkText = NSLocalizedString("watermark_text_label", value: "Watermark Text", comment: "")
        static let logoImage = NSLocalizedString("watermark_logo_label", value: "Logo Image", comment: "")
        static let chooseLogo = NSLocalizedString("watermark_choose_logo", value: "Choose Logo", comment: "")
        static let changeLogo = NSLocalizedString("watermark_change_logo", value: "Change Logo", comment: "")
        static let size = NSLocalizedString("watermark_size", value: "Size", comment: "")
        static let opacity = NSLocalizedString("watermark_opacity", value: "Opacity", comment: "")
        static let applyToAllPages = NSLocalizedString("watermark_apply_all_pages", value: "Apply to all pages", comment: "")
        static let saveTextButton = NSLocalizedString("watermark_save_text_button", value: "Save Text Watermark", comment: "")
        static let saveLogoButton = NSLocalizedString("watermark_save_logo_button", value: "Save Logo Watermark", comment: "")
        static let savedTitle = NSLocalizedString("watermark_saved_title", value: "PDF Watermarked!", comment: "")
    }

    struct PDFAI {
        static let summaryTitle = NSLocalizedString("pdf_ai_summary_title", value: "PDF Summary", comment: "")
        static let keyPointsTitle = NSLocalizedString("pdf_ai_key_points_title", value: "Extract Key Points", comment: "")
        static let notesTitle = NSLocalizedString("pdf_ai_notes_title", value: "Generate Notes", comment: "")
        static let questionAnsweringTitle = NSLocalizedString("pdf_ai_qa_title", value: "Question Answering", comment: "")

        static let summaryDescription = NSLocalizedString("pdf_ai_summary_description", value: "Extract selectable text and save a concise summary.", comment: "")
        static let keyPointsDescription = NSLocalizedString("pdf_ai_key_points_description", value: "Extract important points from selectable PDF text.", comment: "")
        static let notesDescription = NSLocalizedString("pdf_ai_notes_description", value: "Generate structured notes from PDF text.", comment: "")
        static let questionAnsweringDescription = NSLocalizedString("pdf_ai_qa_description", value: "Ask a question and find the most relevant answer in the PDF.", comment: "")

        static let summaryButton = NSLocalizedString("pdf_ai_summary_button", value: "Create Summary", comment: "")
        static let keyPointsButton = NSLocalizedString("pdf_ai_key_points_button", value: "Extract Key Points", comment: "")
        static let notesButton = NSLocalizedString("pdf_ai_notes_button", value: "Generate Notes", comment: "")
        static let questionAnsweringButton = NSLocalizedString("pdf_ai_qa_button", value: "Answer Question", comment: "")
        static let question = NSLocalizedString("pdf_ai_question", value: "Question", comment: "")
        static let questionPlaceholder = NSLocalizedString("pdf_ai_question_placeholder", value: "Ask about this PDF...", comment: "")
        static let processing = NSLocalizedString("pdf_ai_processing", value: "Reading PDF text...", comment: "")
    }

    struct ImageTools {
        static let compressTitle = NSLocalizedString("img_compress_title", value: "Compress Image", comment: "")
        static let resizeTitle = NSLocalizedString("img_resize_title", value: "Resize Image", comment: "")
        static let convertTitle = NSLocalizedString("img_convert_title", value: "Convert Format", comment: "")
        static let editTitle = NSLocalizedString("img_edit_title", value: "Edit Image", comment: "")
        static let webpToJpgTitle = NSLocalizedString("img_webp_to_jpg_title", value: "WEBP to JPG", comment: "")
        static let webpToPngTitle = NSLocalizedString("img_webp_to_png_title", value: "WEBP to PNG", comment: "")
        static let jpgToWebpTitle = NSLocalizedString("img_jpg_to_webp_title", value: "JPG to WEBP", comment: "")
        static let pngToWebpTitle = NSLocalizedString("img_png_to_webp_title", value: "PNG to WEBP", comment: "")
        static let gifToImagesTitle = NSLocalizedString("img_gif_to_images_title", value: "GIF to Images", comment: "")
        static let imagesToGifTitle = NSLocalizedString("img_images_to_gif_title", value: "Images to GIF", comment: "")

        static let qualitySlider = NSLocalizedString("img_quality_slider", value: "Compression Quality", comment: "")
        static let originalSize = NSLocalizedString("img_original_size", value: "Original Size", comment: "")
        static let targetSize = NSLocalizedString("img_target_size", value: "Estimated Target Size", comment: "")
        static let compressBtn = NSLocalizedString("img_compress_btn", value: "Compress and Save", comment: "")

        static let widthLabel = NSLocalizedString("img_width_label", value: "Width (px)", comment: "")
        static let heightLabel = NSLocalizedString("img_height_label", value: "Height (px)", comment: "")
        static let lockAspectRatio = NSLocalizedString("img_lock_ratio", value: "Lock Aspect Ratio", comment: "")
        static let resizeBtn = NSLocalizedString("img_resize_btn", value: "Resize and Save", comment: "")

        static let selectFormat = NSLocalizedString("img_select_format", value: "Select Target Format", comment: "")
        static let convertBtn = NSLocalizedString("img_convert_btn", value: "Convert and Save", comment: "")

        static let rotateLeft = NSLocalizedString("img_rotate_left", value: "Rotate Left", comment: "")
        static let rotateRight = NSLocalizedString("img_rotate_right", value: "Rotate Right", comment: "")
        static let reset = NSLocalizedString("img_reset", value: "Reset", comment: "")
        static let cropBtn = NSLocalizedString("img_crop_btn", value: "Crop and Save", comment: "")
    }

    struct MetadataTools {
        static let removeTitle = NSLocalizedString("metadata_remove_title", value: "Remove Metadata", comment: "")
        static let privacyTitle = NSLocalizedString("metadata_privacy_title", value: "Privacy Cleaner", comment: "")
        static let removeDescription = NSLocalizedString("metadata_remove_description", value: "Select PDFs or images and save a copy with document and image metadata removed.", comment: "")
        static let privacyDescription = NSLocalizedString("metadata_privacy_description", value: "Create a stronger cleaned copy by rebuilding PDFs and re-encoding image pixels where possible.", comment: "")
        static let removeButton = NSLocalizedString("metadata_remove_button", value: "Remove Metadata", comment: "")
        static let privacyButton = NSLocalizedString("metadata_privacy_button", value: "Clean Private Data", comment: "")
        static let processing = NSLocalizedString("metadata_processing", value: "Cleaning metadata...", comment: "")
    }

    struct Utilities {
        static let convertLivePhotosTitle = NSLocalizedString("utilities_convert_live_photos_title", value: "Convert Live Photos", comment: "")
        static let extractFrameTitle = NSLocalizedString("utilities_extract_frame_title", value: "Extract Frame from Video", comment: "")
        static let convertLivePhotosDescription = NSLocalizedString("utilities_convert_live_photos_description", value: "Select Live Photos and export their still image as JPG files.", comment: "")
        static let extractFrameDescription = NSLocalizedString("utilities_extract_frame_description", value: "Select videos and save a JPG frame from the timestamp you enter.", comment: "")
        static let convertLivePhotosButton = NSLocalizedString("utilities_convert_live_photos_button", value: "Convert Live Photos", comment: "")
        static let extractFrameButton = NSLocalizedString("utilities_extract_frame_button", value: "Extract Frame", comment: "")
        static let frameTime = NSLocalizedString("utilities_frame_time", value: "Frame Time (seconds)", comment: "")
        static let processing = NSLocalizedString("utilities_processing", value: "Processing media...", comment: "")
    }

    struct OCR {
        static let title = NSLocalizedString("ocr_title", value: "OCR Text Recognition", comment: "")
        static let selectSource = NSLocalizedString("ocr_select_source", value: "Select Image Source", comment: "")
        static let recognizeBtn = NSLocalizedString("ocr_recognize_btn", value: "Extract Text", comment: "")
        static let copySuccess = NSLocalizedString("ocr_copy_success", value: "Text copied to clipboard!", comment: "")
        static let noTextFound = NSLocalizedString("ocr_no_text", value: "No text recognized in this image.", comment: "")
        static let recognizedTextLabel = NSLocalizedString("ocr_result_label", value: "Recognized Text", comment: "")
    }

    struct Export {
        static let zipTitle = NSLocalizedString("export_zip_title", value: "ZIP Export", comment: "")
        static let cloudTitle = NSLocalizedString("export_cloud_title", value: "Cloud Backup", comment: "")
        static let zipButton = NSLocalizedString("export_zip_button", value: "Create ZIP Export", comment: "")
        static let cloudButton = NSLocalizedString("export_cloud_button", value: "Back Up to iCloud", comment: "")
        static let processing = NSLocalizedString("export_processing", value: "Preparing export...", comment: "")
    }

    struct Files {
        static let title = NSLocalizedString("files_title", value: "My Files", comment: "")
        static let searchPlaceholder = NSLocalizedString("files_search", value: "Search saved documents...", comment: "")
        static let renameTitle = NSLocalizedString("files_rename_title", value: "Rename File", comment: "")
        static let deleteConfirm = NSLocalizedString("files_delete_confirm", value: "Are you sure you want to delete this file?", comment: "")
        static let deleteWarning = NSLocalizedString("files_delete_warning", value: "This action cannot be undone.", comment: "")
        static let emptyState = NSLocalizedString("files_empty_state", value: "No files generated yet.", comment: "")
        static let favoriteOnly = NSLocalizedString("files_favorite_only", value: "Favorites Only", comment: "")
        static let today = NSLocalizedString("files_today", value: "Today", comment: "")
        static let yesterday = NSLocalizedString("files_yesterday", value: "Yesterday", comment: "")
    }

    struct Settings {
        static let title = NSLocalizedString("settings_title", value: "Settings", comment: "")
        static let aboutSection = NSLocalizedString("settings_about", value: "About", comment: "")
        static let legalSection = NSLocalizedString("settings_legal", value: "Legal", comment: "")
        static let versionLabel = NSLocalizedString("settings_version", value: "App Version", comment: "")
        static let contactSupport = NSLocalizedString("settings_contact", value: "Contact Support", comment: "")
        static let privacyPolicy = NSLocalizedString("settings_privacy", value: "Privacy Policy", comment: "")
        static let termsOfUse = NSLocalizedString("settings_terms", value: "Terms of Use", comment: "")
        static let appearanceLabel = NSLocalizedString("settings_appearance", value: "Appearance", comment: "")
        static let lightModeOnly = NSLocalizedString("settings_light_mode", value: "Light Mode Only", comment: "")
    }

    struct States {
        static let processing = NSLocalizedString("state_processing", value: "Processing, please wait...", comment: "")
        static let loadingData = NSLocalizedString("state_loading", value: "Loading data...", comment: "")
        static let errorOccurred = NSLocalizedString("state_error_occurred", value: "An error occurred.", comment: "")
        static let successOccurred = NSLocalizedString("state_success", value: "Operation completed successfully!", comment: "")
    }
}
