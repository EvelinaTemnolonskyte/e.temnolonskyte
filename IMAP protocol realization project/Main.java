
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import java.io.*;
import java.net.Socket;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.Channels;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.nio.charset.StandardCharsets;
import java.util.InputMismatchException;
import java.util.Scanner;
import java.util.TimeZone;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.Date;

import java.util.regex.*;
import java.util.ArrayList;
import java.util.List;



import java.util.Arrays;
import java.util.Base64;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import java.nio.charset.StandardCharsets;
import java.util.Scanner;


public class Main {
    static final String HOST = "outlook.office365.com";
    static final int PORT = 993;
    
    static String EMAIL;
    static String PASSWORD;

    static BufferedReader reader;
    static PrintWriter writer;
    
    static String selectResponse;


    public static void main(String[] args) throws IOException {
        Socket socket = SSLSocketFactory.getDefault().createSocket(HOST, PORT);

        reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        writer = new PrintWriter(new OutputStreamWriter(socket.getOutputStream()));
        Scanner scanner = new Scanner(System.in);
        String tag;
        
        while (true) {
            System.out.println("----------------------LOGIN---------------------");
            System.out.print("Enter your email: ");
            EMAIL = scanner.nextLine();
            System.out.print("Enter your password: ");
            PASSWORD = new String(System.console().readPassword());
	    
            tag = "a1";
            sendCommand(tag, "LOGIN " + EMAIL + " " + PASSWORD);
            String response = readResponseWithReturn(tag);
            System.out.println("Response: " + response);
            System.out.println("---------------------------------------------------------------");
            
            if (response.contains("OK")) {
                System.out.println("Login successful!");
                break;
            } else {
                System.out.println("Login failed. Please try again.");
            }
        }
	    int selection;
   

        do {
            System.out.println("\nSelect an option:");
            System.out.println("1. List mailboxes");
            System.out.println("2. List subscribed mailboxes");
            System.out.println("3. Select folder by name and display mailbox messages by written criteria(+SEARCH, FETCH)");
            System.out.println("4. Create mailbox");
            System.out.println("5. Delete mailbox");
            System.out.println("6. Rename mailbox");
            System.out.println("7. Subscribe to folder");
            System.out.println("8. Unsubscribe from folder");
            System.out.println("9. Check folder status");
            System.out.println("10. Append message to the mailbox");
            System.out.println("11. COPY message to another folder");
            System.out.println("12. Change message flags (STORE)");
            System.out.println("13. Display email according to UID + DECRIPTION");
            System.out.println("14. Save attachements from email");
            System.out.println("15.Encrypt message and save in mailbox APPEND + ENCRYPTION");
            System.out.println("16. LOGOUT");
            System.out.print("Enter your choice: ");

            selection = getUserInput();

            switch (selection) {
                case 1:
                    System.out.print("Enter the namespace or folder (leave empty for root): ");
    		    String namespace = scanner.nextLine();
    		    tag = "a2";
                    sendCommand(tag, "LIST \"" + namespace + "\" \"*\""); 
    		    String listResponse = readMultilineResponse(tag);
    		    System.out.println("Mailboxes in " + namespace + ":");
    		    System.out.println(listResponse);
                    System.out.println("---------------------------------------------------------------");
                    break;
                case 2:
                    System.out.print("Enter the namespace or folder (leave empty for root): ");
    		    String namespaceLSUB = scanner.nextLine();
    		    tag = "a3";
    		    sendCommand(tag, "LSUB \"" + namespaceLSUB + "\" \"*\""); 
    		    String lsubResponse = readMultilineResponse(tag);
    		    System.out.println("Subscribed mailboxes in " + namespaceLSUB + ":");
    		    System.out.println(lsubResponse);
    		    System.out.println("---------------------------------------------------------------");
                    break;
                case 3:
                    System.out.print("Enter folder name: ");
    						String folderName = scanner.nextLine();
    						tag = "a4";
    						sendCommand(tag, "SELECT \"" + folderName + "\"");
    						selectResponse = readResponseWithReturn(tag);
    						
    						if (selectResponse.startsWith(tag + " NO")) {
    							System.out.println("Mailbox not found. Exiting...");
    							System.out.println("---------------------------------------------------------------");
   							break; 
						}
						
    						 System.out.println("---------------------------------------------------------------");
    						int folderSelection;
    						do {
        							System.out.println("Folder \"" + folderName + "\" selected. What would you like to do?");
        							System.out.println("1. Search Emails");
        							System.out.println("2. Exit from Folder Selection");
        							System.out.print("Enter your choice: ");
        							folderSelection = getUserInput();
        							switch (folderSelection) {
            						case 1:
   										tag = "a5";
   									        System.out.print("Enter SEARCH criteria: ");
    									        String criteria = scanner.nextLine();
   				
                								sendCommand(tag, "SEARCH " + criteria);
                								
                								String searchResponse = readMultilineResponse(tag); 
                								System.out.print(searchResponse);
                								
                								if (searchResponse.startsWith(tag + " BAD")) {
    											System.out.println("No such criteria. Exiting...");
    										System.out.println("---------------------------------------------------------------");
   											break; 
										}
                								
                								
                								System.out.println("---------------------------------------------------------------");
                								List<Integer> numbersList = new ArrayList<>();
    										

    										Pattern pattern = Pattern.compile("\\b\\d+\\b");
    										Matcher matcher = pattern.matcher(searchResponse);
    										while (matcher.find()) {
        										int number = Integer.parseInt(matcher.group());
        										numbersList.add(number);
    										}

    
    										Integer[] numbersArray = numbersList.toArray(new Integer[0]);

    
    										if (numbersArray.length == 0) {
        										System.out.println("No messages found according to search criteria.");
    										} else {
        
        										StringBuilder fetchCommand = new StringBuilder("FETCH ");
       											for (int i = 0; i < numbersArray.length; i++) {
            											fetchCommand.append(numbersArray[i]);
            											if (i < numbersArray.length - 1) {
                											fetchCommand.append(",");
            											}
        										}
        										fetchCommand.append(" (UID BODY[HEADER.FIELDS (FROM SUBJECT DATE)])");

        
        										tag = "a6"; 
        										sendCommand(tag, fetchCommand.toString());

        
        										String fetchResponse = readMultilineResponse(tag);
        										System.out.println("FETCH response:");
        										System.out.println(fetchResponse);
    										}
    										System.out.println("---------------------------------------------------------------");
    										break;
    
            						case 2:
                								System.out.println("Exiting from Folder Selection...");
               								break;
            					default:
                								System.out.println("Invalid selection. Please try again.");
        							}
   	 					} while (folderSelection != 2);
    						
    						break;
    				 case 4:
    				 		System.out.print("Enter the name of the new folder: ");
    						String newFolderName = scanner.nextLine();
    						tag = "a6";
    						sendCommand(tag, "CREATE \"" + newFolderName + "\"");
    						readResponse(tag);
    						System.out.println("---------------------------------------------------------------");
    						break;
    				case 5:
    						System.out.print("Enter the name of the folder to delete: ");
    						String folderToDelete = scanner.nextLine();
    						tag = "a7";
    						sendCommand(tag, "DELETE \"" + folderToDelete + "\"");
    						readResponse(tag);
    						System.out.println("---------------------------------------------------------------");
    						break;
					case 6:
    						System.out.print("Enter the current name of the folder: ");
    						String currentFolderName = scanner.nextLine();
    						System.out.print("Enter the new name for the folder: ");
    						newFolderName = scanner.nextLine();
    						tag = "a8";
    						sendCommand(tag, "RENAME \"" + currentFolderName + "\" \"" + newFolderName + "\"");
    						readResponse(tag);
    						System.out.println("---------------------------------------------------------------");
    						break;
    				case 7:
    						System.out.print("Enter the name of the folder to subscribe: ");
    						String folderToSubscribe = scanner.nextLine();
    						tag = "a9";
    						sendCommand(tag, "SUBSCRIBE \"" + folderToSubscribe + "\"");
    						readResponse(tag);
    						System.out.println("Subscribed to folder: " + folderToSubscribe);
    						System.out.println("---------------------------------------------------------------");
    						break;
					case 8:
    						System.out.print("Enter the name of the folder to unsubscribe: ");
    						String folderToUnsubscribe = scanner.nextLine();
    						tag = "a10";
    						sendCommand(tag, "UNSUBSCRIBE \"" + folderToUnsubscribe + "\"");
    						readResponse(tag);
    						System.out.println("Unsubscribed from folder: " + folderToUnsubscribe);
    						System.out.println("---------------------------------------------------------------");
    						break;
    				case 9:
    						System.out.print("Enter the name of the folder to check status: ");
    						String folderToCheck = scanner.nextLine();
    						tag = "a11";
    						sendCommand(tag, "STATUS \"" + folderToCheck + "\" (MESSAGES RECENT UNSEEN UIDNEXT UIDVALIDITY)");
    						readResponse(tag);
    						System.out.println("---------------------------------------------------------------");
    						break;
    				case 10:
    						 
    						 System.out.println("Enter foulder: ");
   						 String folder = scanner.nextLine();
    						 System.out.println("Enter recipient email: ");
   					         String recipient = scanner.nextLine();
    						 System.out.println("Enter subject: ");
    						 String subject = scanner.nextLine();
    						 System.out.println("Enter message body: ");
    						 StringBuilder bodyBuilder = new StringBuilder();
    						 String line;
    						 while (!(line = scanner.nextLine()).isEmpty()) {
        						bodyBuilder.append(line).append("\n");
    						 }
    						 String body = bodyBuilder.toString();
						 appendMessage(folder, recipient, EMAIL, subject, body);

    						 break;
    			        case 11:
    						System.out.println("Enter source folder: ");
    						String sourceFolder = scanner.nextLine();
    						
    						tag = "a12";
   					 	sendCommand(tag, "SELECT \"" + sourceFolder + "\"");
    						
    						selectResponse = readResponseWithReturn(tag);
    						


						if (selectResponse.startsWith(tag + " NO")) {
    							System.out.println("Mailbox not found. Exiting...");
    							System.out.println("---------------------------------------------------------------");
   							break; 
						}
						System.out.println("Enter destination folder: ");
    						String destinationFolder = scanner.nextLine();
    						System.out.println("Enter UID of the message to copy: ");
    						int uid = scanner.nextInt();

    						tag = "a13";
    						sendCommand(tag, "UID COPY " + uid + " \"" + destinationFolder + "\"");
    						readResponse(tag);
    						System.out.println("---------------------------------------------------------------");
    						break;	
				case 12:

    						System.out.print("Enter the folder name to select: ");
    						String selectedFolder = scanner.nextLine();
    						tag = "a14";
    						sendCommand(tag, "SELECT \"" + selectedFolder + "\"");
    						selectResponse = readMultilineResponse(tag);
    						System.out.println(selectResponse);


						if (selectResponse.startsWith(tag + " NO")) {
    							System.out.println("Mailbox not found. Exiting...");
    							System.out.println("---------------------------------------------------------------");
   							break; 
						}

    						tag = "a15";
    						sendCommand(tag, "SEARCH ALL");
    						String searchResponse = readMultilineResponse(tag);
    						System.out.println("Search results: " + searchResponse);
    
    						System.out.print("Enter the sequence set (e.g., message numbers): ");
    						String sequenceSet = scanner.nextLine();
    						System.out.print("Enter the data item name (e.g., FLAGS (change), +FLAGS to add a flag, -FLAGS to remove a flag): ");
    						String dataItemName = scanner.nextLine();
    						System.out.print("Enter the value for the data item , for example : (\\Draft): ");
    						String value = scanner.nextLine();

    						String storeCommand = "STORE " + sequenceSet + " " + dataItemName + " " + value;
    						System.out.println("Sending STORE command: " + storeCommand);

    						sendCommand(tag, storeCommand);
    
   						readResponse(tag);

    						System.out.println("---------------------------------------------------------------");
    						break;
    					case 13:
    						System.out.print("Enter folder name: ");	
    					        folderName = scanner.nextLine();
    						tag = "a4";
    						sendCommand(tag, "SELECT \"" + folderName + "\"");
    						selectResponse = readResponseWithReturn(tag);
    						
    						if (selectResponse.startsWith(tag + " NO")) {
    							System.out.println("Mailbox not found. Exiting...");
    							System.out.println("---------------------------------------------------------------");
   							break; 
						}
						
    						 System.out.println("---------------------------------------------------------------");
    						 tag = "a5";
   						 System.out.print("Enter email UID:  ");
    				                 String uidEmail = scanner.nextLine();
   				
                				 sendCommand(tag, "SEARCH " + uidEmail);
                				 readResponse(tag); 
                				 sendCommand(tag, "FETCH " + uidEmail +" (BODY.PEEK[HEADER.FIELDS (FROM SUBJECT)] BODY.PEEK[TEXT])");
                				 ArrayList<String> fetchResponse1 = readResponseList(tag);
                				 String sender = null;
						 subject = null;
						 StringBuilder text = new StringBuilder();

						 boolean inTextSection = false;

						boolean hasContentType = false;
						for (String lineFetch : fetchResponse1) {
    							if (lineFetch.startsWith("Content-Type:")) {
        							hasContentType = true;
        							break;
    							}
						}


						if (hasContentType) {
    							for (String lineResponse : fetchResponse1) {
        							if (lineResponse.startsWith("From: ") && sender == null) {
            								sender = lineResponse.substring(lineResponse.indexOf("<") + 1, lineResponse.indexOf(">"));
        							}
        							if (lineResponse.startsWith("Subject: ") && subject == null) {
            									subject = lineResponse.substring(9);
        							}

        							if (lineResponse.startsWith("Content-Type: text/plain;") && !inTextSection) {
            									inTextSection = true;
            									continue;
        							}
        							if (lineResponse.startsWith("--") && inTextSection) {
            									break;
        							}

        							if (inTextSection) {
            								text.append(lineResponse).append(System.getProperty("line.separator"));
        							}
   						 	}
   						}else {
    
    							boolean bodyStarted = false;
    							if (!fetchResponse1.isEmpty()) {
    								fetchResponse1.remove(fetchResponse1.size() - 1); 
    							}
    							for (String line2 : fetchResponse1) {
    								if (!bodyStarted) {
        								if (line2.startsWith("From: ")) {
            									sender = line2.substring(line2.indexOf(":") + 2).trim(); 
        								} else if (line2.startsWith("Subject: ")) {
            									subject = line2.substring(line2.indexOf(":") + 2).trim(); 
        								} else if (line2.contains("BODY[TEXT]")) {
            									bodyStarted = true; 
        								}
    								} else {
        								if (!line2.trim().equals(")")) {
            									text.append(line2).append(System.getProperty("line.separator")); 
        								}
    								}
							}
						}						
    						String emailText = text.toString();
    						
						if (sender != null && subject != null) {
    							System.out.println("Sender: " + sender);
    							System.out.println("Subject: " + subject);
    							System.out.println("Text Body:");
    							System.out.println(emailText);
						} else {
    							System.out.println("Failed to parse email.");
						}
						
						System.out.print("Do you want to decrypt the message? (yes/no): ");
						String decryptChoice = scanner.nextLine();

						switch (decryptChoice.toLowerCase()) {
    							case "yes":
        							
        							
        						String key = readKey();
							emailText = emailText.replaceAll("(?m)^Content-Transfer-Encoding.*$", "");  
							emailText = emailText.replaceAll("=", ""); 
							emailText = emailText.replaceAll("\\s", ""); 
							System.out.println(emailText);
							byte[] decrypted = decryptMessage(key, decodeBase64(emailText));
							System.out.println("-----------------DECRYPTED MESSAGE-------------------");
							System.out.print(new String(decrypted, StandardCharsets.UTF_8).trim());
							System.out.println("\n");
							break;

    							case "no":
        							System.out.println("Message will not be decrypted.");
        							break;
    							default:
        							System.out.println("Invalid choice. Message will not be decrypted.");
						}				
						break;
				case 14:
				
					System.out.print("Enter folder name: ");
    					folderName = scanner.nextLine();
    					tag = "a4";
    					sendCommand(tag, "SELECT \"" + folderName + "\"");
   				 	selectResponse = readResponseWithReturn(tag);

    					if (selectResponse.startsWith(tag + " NO")) {
        					System.out.println("Mailbox not found. Exiting...");
        					System.out.println("---------------------------------------------------------------");
        					break;
    					}

    					System.out.println("---------------------------------------------------------------");
    					tag = "a5";
    					System.out.print("Enter email UID: ");
    					uidEmail = scanner.nextLine();

    					sendCommand(tag, "FETCH " + uidEmail + " (BODY.PEEK[HEADER.FIELDS (FROM SUBJECT)] BODY.PEEK[TEXT])");
    					ArrayList<String> responseList = readResponseList(tag);
    
    
    					ArrayList<FileInfo> files = parseFiles(responseList);
    					
    					System.out.println("/n/n");
    					System.out.println("-----------FILE CREATION ---------------------");
    					if (!files.isEmpty()) {
        					System.out.println("Files found in the email:");
        					for (FileInfo file : files) {
            						System.out.println("Creating file: " + file.getFileName());
            						createFile(file);
        					}
    					} else {
        					System.out.println("No files found in the email.");
    					}
    					break;	
    			case 15: 
    			
    						 
    						 System.out.println("Enter foulder: ");
   						 folder = scanner.nextLine();
    						 System.out.println("Enter recipient email: ");
   					         recipient = scanner.nextLine();
    						 System.out.println("Enter subject: ");
    						 subject = scanner.nextLine();
    						 System.out.println("Enter message body: ");
    						 bodyBuilder = new StringBuilder();
    						
    						 while (!(line = scanner.nextLine()).isEmpty()) {
        						bodyBuilder.append(line).append("\n");
    						 }
    						 body = bodyBuilder.toString();
    						 
    						 
        
        					String key = readKey();

        					byte[] encrypted = encryptMessage(key, body);
        					System.out.println("This is your encrypted message:");
        					String encryptedBody = encodeBase64(encrypted);
        					appendMessage(folder, recipient, EMAIL, subject, encryptedBody);
    						 
						break;
		
 	
              case 16:
                	  tag = "a9";
                	  sendCommand(tag, "LOGOUT");
                    readResponse(tag);
                    break;             
                default:
                    System.out.println("Invalid selection. Please try again.");
            }
        } while (selection != 16);

        socket.close();
        
    }

    public static void readResponse(String tag) throws IOException {
        String line;
        while ((line = reader.readLine()) != null) {
            System.out.println(line);
            if (line.startsWith(tag)) {
                break;
            }
        }
    } 
    
     public static String readResponseWithReturn(String tag) throws IOException {
        String line;
        while ((line = reader.readLine()) != null) {
            System.out.println(line);
            if (line.startsWith(tag)) {
                break;
            }
        }
        return line;
    } 
    

    
    

    public static void sendCommand(String tag, String command) {
        writer.print(tag + " " + command + "\r\n");
        writer.flush();
    }
    
    
	
    public static int getUserInput() {
        Scanner scanner = new Scanner(System.in);
        int selection;
        try {
            selection = scanner.nextInt();
        } catch (Exception e) {
            selection = -1;
        }

        return selection;
    }
    
    public static String readMultilineResponse(String tag) throws IOException {
    StringBuilder response = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
        response.append(line).append("\n");
        if (line.startsWith(tag)) {
            break;
        }
    }
    return response.toString();
}

 public static boolean appendMessage(String folder, String to, String sender, String subject, String body) {
        String tag = "append";
        SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z");
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        String currentDate = dateFormat.format(new Date());
        String messageId = "<" + generateMessageId() + ">";
        
        String message = "From: " + sender + "\r\n" +
                         "To: " + to + "\r\n" +
                         "Subject: " + subject + "\r\n" +
                         "Date: " + currentDate + "\r\n" +
                         "Message-Id: " + messageId + "\r\n" +
                         "MIME-Version: 1.0\r\n" +
                         "Content-Type: TEXT/PLAIN; CHARSET=US-ASCII\r\n" +
                         "\r\n" +
                         body;
        
        int messageLength = message.getBytes(StandardCharsets.UTF_8).length;
        String command = "APPEND " + folder + " (\\Seen) {" + messageLength + "}\r\n" + message;
        sendCommand(tag, command);
        try {
        String response = readResponseWithReturn(tag);
        if (response.contains("OK")) {
            return true; 
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
    return false; 
    }
    
    
   
 

    
    private static String generateMessageId() {
        return Long.toString(System.currentTimeMillis());
    }
    
    private static ArrayList<String> readResponseList(String tag) throws IOException {
    ArrayList<String> responseList = new ArrayList<>();
    String response;
    while ((response = reader.readLine()) != null) {
        System.out.println(response);
        responseList.add(response);
        if (response.startsWith(tag + " OK") || response.startsWith(tag + " NO") || response.startsWith(tag + " BAD")) {
            break;
        }
    }
    return responseList;
}

private static ArrayList<FileInfo> parseFiles(List<String> response) {
    ArrayList<FileInfo> files = new ArrayList<>();
    boolean dataReadingMode = false;
    StringBuilder data = new StringBuilder();
    String fileName = null;

    for (String line : response) {
        if (line.startsWith("Content-Disposition:")) {
            fileName = line.substring(line.indexOf("filename=\"") + 10, line.lastIndexOf("\""));
            continue;
        }

        if (line.startsWith("--")) {
            if (line.startsWith("--_")) { 
                if (dataReadingMode) { 
                    files.add(new FileInfo(fileName, Base64.getDecoder().decode(data.toString())));
                    data = new StringBuilder(); 
                    fileName = null;
                }
                dataReadingMode = false; 
            } else if (line.startsWith("--_") && line.endsWith("--")) { 
                break;
            }
            continue;
        }

        if (line.startsWith("Content-Transfer-Encoding:")) {
            if (line.endsWith("base64")) {
                dataReadingMode = true; 
            } else {
                dataReadingMode = false; 
            }
            continue;
        }

        if (dataReadingMode) {
            data.append(line);
        }
    }

    if (dataReadingMode && fileName != null) { 
        files.add(new FileInfo(fileName, Base64.getDecoder().decode(data.toString())));
    }

    System.out.println("Files array:");
    return files;
}

   
    
    private static void createFile(FileInfo fileInfo) {
    Path path = Paths.get("attachments");
    File file = new File(path.toFile(), fileInfo.name);

    try {
        Files.createDirectories(path);

        if (file.exists()) {
           
            System.out.println("A file with the same name '" + fileInfo.name + "' already exists.");
            System.out.println("Do you want to rename or replace it? (Type 'rename' or 'replace'):");
            BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
            String userInput = reader.readLine().trim();

            if (userInput.equalsIgnoreCase("rename")) {
                System.out.println("Enter new file name:");
                String newFileName = reader.readLine().trim();
                String fileExtension = fileInfo.name.substring(fileInfo.name.lastIndexOf('.'));
               
                newFileName += fileExtension;
                file = new File(path.toFile(), newFileName);
            } else if (!userInput.equalsIgnoreCase("replace")) {
               
                System.out.println("No action taken.");
                return;
            }
        }

       
            try (FileOutputStream outputStream = new FileOutputStream(file)) {
                outputStream.write(fileInfo.data);
                System.out.println("File downloaded successfully!");
            } catch (IOException e) {
                System.out.println("FileOutputStream: " + e.getMessage());
            }
        
    } catch (IOException e) {
        System.out.println("File: " + e.getMessage());
    }
}

public static String readKey() throws IOException {
        
        String filePath = "/stud3/2022/evte9199/Downloads/key.txt";
        File file = new File(filePath);
        BufferedReader br = new BufferedReader(new FileReader(file));
        StringBuilder key = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            key.append(line);
        }
        return key.toString();
    }

    public static void toFile(String mes) {
        try {
            
	    FileOutputStream fos = new FileOutputStream("/stud3/2022/evte9199/Downloads/filename.txt");
            fos.write(mes.getBytes(StandardCharsets.UTF_8));
            fos.close();
            System.out.println("Successfully wrote to the file.");
        } catch (IOException e) {
            System.out.println("An error occurred.");
            e.printStackTrace();
        }
    }

public static byte[] decodeBase64(String base64String) {
        return Base64.getDecoder().decode(base64String);
    }


    public static byte[] encryptMessage(String key, String message) {
        byte[] k = key.getBytes(StandardCharsets.UTF_8);
        byte[] m = message.getBytes(StandardCharsets.UTF_8);
        byte[] ciphertext = new byte[m.length];
        for (int i = 0; i < m.length; i++) {
            ciphertext[i] = (byte) (m[i] ^ k[i % k.length]);
        }
        return ciphertext;
    }

    public static byte[] decryptMessage(String key, byte[] encrypted) {
        byte[] k = key.getBytes(StandardCharsets.UTF_8);
        byte[] decrypted = new byte[encrypted.length];
        for (int i = 0; i < encrypted.length; i++) {
            decrypted[i] = (byte) (encrypted[i] ^ k[i % k.length]);
        }
        return decrypted;
    }

    public static String encodeBase64(byte[] bytes) {
        return Base64.getEncoder().encodeToString(bytes);
    }

	

}
