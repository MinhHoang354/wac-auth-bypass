#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Khai báo lại cấu trúc khối (Block) completion của ứng dụng
typedef void (^CateCompletionBlock)(id responseObject, id error);

// Tiến hành hook vào lớp CateAPI
%hook CateAPI

- (void)requestAction:(id)action parameters:(id)parameters completion:(CateCompletionBlock)completion {
    
    // Tạo một block mới để hứng và ghi đè dữ liệu trả về từ máy chủ
    CateCompletionBlock fakeCompletion = ^(id responseObject, id error) {
        if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]]) {
            
            // Tạo bản sao có thể chỉnh sửa (Mutable Copy) từ gói tin gốc
            NSMutableDictionary *mutableResponse = [responseObject mutableCopy];
            
            // 1. GÁN ĐÈ 100% CẤU TRÚC GÓI TIN ĐĂNG NHẬP VIP THÀNH CÔNG TỪ KEY TEST CỦA BẠN
            [mutableResponse setObject:@"ADMIN" forKey:@"account_tier"];
            [mutableResponse setObject:@"" forKey:@"bundle_id"];
            [mutableResponse setObject:@"https://t.me" forKey:@"contact"];
            [mutableResponse setObject:@"Liên hệ" forKey:@"contact_button_text"];
            [mutableResponse setObject:@0 forKey:@"days_left"];
            [mutableResponse setObject:@"" forKey:@"description"];
            [mutableResponse setObject:@"2036-10-27 00:13:28" forKey:@"expiry"]; // Đổi năm sang 2036 để dùng vĩnh viễn
            [mutableResponse setObject:@"Active" forKey:@"message"];
            [mutableResponse setObject:@"" forKey:@"notification"];
            [mutableResponse setObject:@"default" forKey:@"notification_style"];
            [mutableResponse setObject:@"OK" forKey:@"ok_button_text"];
            [mutableResponse setObject:@"Play Together" forKey:@"package_name"];
            [mutableResponse setObject:@"1.0" forKey:@"package_version"];
            [mutableResponse setObject:@1 forKey:@"status"];
            [mutableResponse setObject:@"https://t.me" forKey:@"update_link"];
            
            // Triệt tiêu lệnh ép thoát game của hệ thống bảo mật
            if ([mutableResponse objectForKey:@"force_exit"]) {
                [mutableResponse setObject:@0 forKey:@"force_exit"];
            }
            
            // 2. GIẢ LẬP MẢNG TÍNH NĂNG BẢO MẬT SẠCH (BYPASS UDID CỨNG)
            NSMutableDictionary *fakeFeatures = [[NSMutableDictionary alloc] init];
            [fakeFeatures setObject:@0 forKey:@"check_bundle_id"];
            [fakeFeatures setObject:@0 forKey:@"check_hash"];
            [fakeFeatures setObject:@0 forKey:@"force_update"];
            [fakeFeatures setObject:@0 forKey:@"free_login"];
            [fakeFeatures setObject:@0 forKey:@"hide_screen_recording"];
            [fakeFeatures setObject:@0 forKey:@"remind_update"];
            [fakeFeatures setObject:@0 forKey:@"require_real_udid"]; // Bẻ khóa yêu cầu UDID phần cứng
            [fakeFeatures setObject:@1 forKey:@"track_online"];
            [mutableResponse setObject:fakeFeatures forKey:@"features"];
            
            // 3. ĐÓNG BĂNG SỐ GIÂY (HEARTBEAT LOOP PING) VĨNH VIỄN Ở MỨC 4 TIẾNG
            [mutableResponse setObject:@14400 forKey:@"seconds_left"];
            
            // Truyền gói dữ liệu VIP đã được tối ưu ngược lại cho game xử lý
            completion(mutableResponse, error);
        } else {
            // Nếu gói tin không hợp lệ, giữ nguyên luồng chạy gốc để tránh crash
            completion(responseObject, error);
        }
    };
    
    // Thực thi hàm gốc của game nhưng thay bằng block fake dữ liệu của chúng ta
    %orig(action, parameters, fakeCompletion);
}

%end

// Ép chứng thực trạng thái authorized của dylib luôn thành công
%hook CateAPI
- (BOOL)runtimeAuthorized {
    return YES;
}
%end
