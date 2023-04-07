----------Lab8----------
---------cau1------------
go
CREATE PROCEDURE Cau1
    @manv NVARCHAR(10),
    @gioitinh NVARCHAR(3),
    @diachi NVARCHAR(50),
    @email NVARCHAR(50),
    @phong NVARCHAR(50),
    @flag INT
AS
BEGIN
   
    IF (@gioitinh <> N'Nam' AND @gioitinh <> N'Nữ')
    BEGIN
        SELECT 1 AS 'MaLoi', 'Giới tính không hợp lệ' AS 'MoTaLoi'
        RETURN
    END
    
  
    IF (@flag = 0)
    BEGIN
        INSERT INTO nhanvien (manv, gioitinh, diachi, email, phong)
        VALUES (@manv, @gioitinh, @diachi, @email, @phong)
        SELECT 0 AS 'MaLoi', 'Thêm mới nhân viên thành công' AS 'MoTaLoi'
    END
    -- Ngược lại, flag = 1 thì cập nhật thông tin nhân viên
    ELSE
    BEGIN
        UPDATE nhanvien
        SET gioitinh = @gioitinh,
            diachi = @diachi,
            email = @email,
            phong = @phong
        WHERE manv = @manv
        SELECT 0 AS 'MaLoi', 'Cập nhật thông tin nhân viên thành công' AS 'MoTaLoi'
    END
END
go

--cau2--
go
CREATE PROCEDURE ThemCapNhatSanPham
    @masp INT,
    @tenhang NVARCHAR(50),
    @tensp NVARCHAR(50),
    @soluong INT,
    @mausac NVARCHAR(20),
    @giaban FLOAT,
    @donvitinh NVARCHAR(10),
    @mota NVARCHAR(MAX),
    @flag INT
AS
BEGIN
    DECLARE @mahangsx INT

    -- Kiểm tra xem tenhang có tồn tại trong bảng hangsx hay không
    SELECT @mahangsx = mahangsx FROM hangsx WHERE tenhang = @tenhang
    IF @mahangsx IS NULL
    BEGIN
        -- Trả về mã lỗi 1 nếu tenhang không tồn tại trong bảng hangsx
        SELECT 1 AS [ErrorCode], 'Ten hang khong ton tai' AS [Message]
        RETURN
    END

    -- Kiểm tra số lượng sản phẩm
    IF @soluong < 0
    BEGIN
        -- Trả về mã lỗi 2 nếu soluong < 0
        SELECT 2 AS [ErrorCode], 'So luong khong hop le' AS [Message]
        RETURN
    END

    IF @flag = 0 -- Thêm mới sản phẩm
    BEGIN
        INSERT INTO sanpham(masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES(@masp, @mahangsx, @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)

        SELECT 0 AS [ErrorCode], 'Them san pham thanh cong' AS [Message]
    END
    ELSE -- Cập nhật thông tin sản phẩm
    BEGIN
        UPDATE sanpham
        SET mahangsx = @mahangsx,
            tensp = @tensp,
            soluong = @soluong,
            mausac = @mausac,
            giaban = @giaban,
            donvitinh = @donvitinh,
            mota = @mota
        WHERE masp = @masp

        SELECT 0 AS [ErrorCode], 'Cap nhat san pham thanh cong' AS [Message]
    END
END
go
--cau3--
CREATE PROCEDURE XoaNhanVien
    @manv NVARCHAR(10)
AS
BEGIN
    -- Kiểm tra xem mã nhân viên có tồn tại trong bảng nhanvien hay không
    IF NOT EXISTS (SELECT * FROM nhanvien WHERE manv = @manv)
    BEGIN
        -- Nếu không tồn tại, trả về mã lỗi 1
        SELECT 1 AS 'ErrorCode'
        RETURN
    END
    
    -- Xóa dữ liệu của nhân viên trong bảng Nhập và Xuat
    DELETE FROM Nhap WHERE manv = @manv
    DELETE FROM Xuat WHERE manv = @manv
    
    -- Xóa dữ liệu của nhân viên trong bảng nhanvien
    DELETE FROM nhanvien WHERE manv = @manv
    
    -- Trả về mã lỗi 0 để cho biết xóa thành công
    SELECT 0 AS 'ErrorCode'
END
----------cau4------------
CREATE PROCEDURE delete_sanpham(@masp VARCHAR(10))
AS
BEGIN
    -- Kiểm tra xem sản phẩm có tồn tại trong bảng sanpham không
    IF NOT EXISTS (SELECT * FROM sanpham WHERE masp = @masp)
    BEGIN
        -- Nếu không tồn tại, trả về mã lỗi 1
        SELECT 1 AS 'ErrorCode'
        RETURN
    END
    
    -- Xóa thông tin sản phẩm trong bảng Nhap
    DELETE FROM Nhap WHERE masp = @masp
    
    -- Xóa thông tin sản phẩm trong bảng Xuat
    DELETE FROM Xuat WHERE masp = @masp
    
    -- Xóa thông tin sản phẩm trong bảng sanpham
    DELETE FROM sanpham WHERE masp = @masp
    
    -- Trả về mã lỗi 0
    SELECT 0 AS 'ErrorCode'
END
------------cau5-------------
CREATE PROCEDURE themHangsx 
    @mahangsx varchar(10),
    @tenhang nvarchar(50),
    @diachi nvarchar(100),
    @sodt varchar(20),
    @email varchar(50)
AS
BEGIN
    SET NOCOUNT ON;
    -- Kiểm tra xem tên hãng sản xuất đã tồn tại hay chưa
    IF EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
    BEGIN
        -- Trả về mã lỗi 1 nếu tên hãng sản xuất đã tồn tại
        SELECT 1 AS [ErrorCode]
        RETURN
    END

    -- Thêm mới hãng sản xuất vào bảng
    INSERT INTO Hangsx (mahangsx, tenhang, diachi, sodt, email)
    VALUES (@mahangsx, @tenhang, @diachi, @sodt, @email)

    -- Trả về mã lỗi 0 nếu thêm mới thành công
    SELECT 0 AS [ErrorCode]
    RETURN
END
----------cau6-------------
CREATE PROCEDURE sp_NhapHang
    @sohdn nvarchar(50),
    @masp nvarchar(50),
    @manv nvarchar(50),
    @ngaynhap date,
    @soluongN int,
    @dongiaN float
AS
BEGIN
    -- Kiểm tra xem masp có tồn tại trong bảng Sanpham hay không
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        -- Nếu không, trả về mã lỗi 1
        SELECT 1 AS ErrorCode, 'Mã sản phẩm không tồn tại' AS ErrorMessage
        RETURN
    END
    
    -- Kiểm tra xem manv có tồn tại trong bảng Nhanvien hay không
    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        -- Nếu không, trả về mã lỗi 2
        SELECT 2 AS ErrorCode, 'Mã nhân viên không tồn tại' AS ErrorMessage
        RETURN
    END
    
    -- Kiểm tra xem sohdn đã tồn tại trong bảng Nhap hay chưa
    IF EXISTS (SELECT * FROM Nhap WHERE sohdn = @sohdn)
    BEGIN
        -- Nếu đã tồn tại, cập nhật bảng Nhap theo sohdn
        UPDATE Nhap
        SET masp = @masp,
            manv = @manv,
            ngaynhap = @ngaynhap,
            soluongN = @soluongN,
            dongiaN = @dongiaN
        WHERE sohdn = @sohdn
        
        -- Trả về mã lỗi 0
        SELECT 0 AS ErrorCode, 'Cập nhật dữ liệu thành công' AS ErrorMessage
        RETURN
    END
    ELSE
    BEGIN
        -- Nếu chưa tồn tại, thêm mới bảng Nhap
        INSERT INTO Nhap (sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
        VALUES (@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN)
        
        -- Trả về mã lỗi 0
        SELECT 0 AS ErrorCode, 'Thêm mới dữ liệu thành công' AS ErrorMessage
        RETURN
    END
END
-----------cau7------------
CREATE PROCEDURE sp_NhapXuat_Xuat
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
AS
BEGIN
    --Kiểm tra sự tồn tại của masp trong bảng Sanpham
    IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        RETURN 1 --Mã lỗi 1: masp không tồn tại trong bảng Sanpham
    END
    
    --Kiểm tra sự tồn tại của manv trong bảng Nhanvien
    IF NOT EXISTS(SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        RETURN 2 --Mã lỗi 2: manv không tồn tại trong bảng Nhanvien
    END
    
    --Kiểm tra số lượng tồn kho của sản phẩm
    IF @soluongX > (SELECT soluong FROM Sanpham WHERE masp = @masp)
    BEGIN
        RETURN 3 --Mã lỗi 3: số lượng xuất vượt quá số lượng tồn kho của sản phẩm
    END
    
    --Kiểm tra sự tồn tại của sohdx
    IF EXISTS(SELECT * FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        --Cập nhật bảng Xuat
        UPDATE Xuat
        SET masp = @masp,
            manv = @manv,
            ngayxuat = @ngayxuat,
            soluongX = @soluongX
        WHERE sohdx = @sohdx
    END
    ELSE
    BEGIN
        --Thêm mới bảng Xuat
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES(@sohdx, @masp, @manv, @ngayxuat, @soluongX)
    END
    
    --Trả về mã lỗi 0: không có lỗi
    RETURN 0
END