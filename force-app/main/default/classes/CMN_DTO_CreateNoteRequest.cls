/**
 * @description Wrapper class for Create Note API request
 *
 * @author Gnitsevich Anton
 *
 * @date October 2021
 */
public with sharing class CMN_DTO_CreateNoteRequest {
    public String comments { get; set; }
    public String notepadType { get; set; }
    public String user { get; set; }
    public String dt { get; set; }
    public String customer { get; set; }
}