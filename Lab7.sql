-------------lab7------------------
----cau1------------- 
CREATE PROCEDURE them_hangsx (@mahangsx INT, @tenhang VARCHAR(50), @diachi VARCHAR(50), @sodt VARCHAR(15), @email VARCHAR(50))
AS
BEGIN
    IF EXISTS (SELECT * FROM Hangsx WHERE tenhang = @tenhang)
        PRINT N'Tên hàng đã tồn tại trong cơ sở dữ liệu.'
    ELSE
        INSERT INTO Hangsx(mahangsx, tenhang, diachi, sodt, email) VALUES (@mahangsx, @tenhang, @diachi, @sodt, @email)
END
EXEC them_hangsx @mahangsx = 123, @tenhang = N'Samsung1', @diachi = N'Hàn Quốc', @sodt = N'0123456789', @email = N'contact@samsung.com'
-- cau 2
go
CREATE PROCEDURE ThemSuaSanPham
    @masp NVARCHAR(10),
    @mahangsx NVARCHAR(10),
    @tensp NVARCHAR(50),
    @soluong INT,
    @mausac NVARCHAR(20),
    @giaban FLOAT,
    @donvitinh NVARCHAR(20),
    @mota NVARCHAR(200)
AS
BEGIN
    IF EXISTS (SELECT * FROM sanpham WHERE masp = @masp)
    BEGIN
        UPDATE sanpham SET 
            mahangsx = @mahangsx,
            tensp = @tensp,
            soluong = @soluong,
            mausac = @mausac,
            giaban = @giaban,
            donvitinh = @donvitinh,
            mota = @mota
        WHERE masp = @masp
    END
    ELSE
    BEGIN
        INSERT INTO sanpham (masp, mahangsx, tensp, soluong, mausac, giaban, donvitinh, mota)
        VALUES (@masp, @mahangsx, @tensp, @soluong, @mausac, @giaban, @donvitinh, @mota)
    END
END

-- cau 3
go
CREATE PROCEDURE XoaHangSX
    @tenhang nvarchar(50)
AS
BEGIN
    IF NOT EXISTS(SELECT * FROM hangsx WHERE tenhang = @tenhang)
    BEGIN
        PRINT N'Hãng sản xuất không tồn tại.'
        RETURN
    END

    BEGIN TRANSACTION

    -- Xóa các sản phẩm của hãng hàng hóa
    DELETE FROM sanpham
    WHERE mahangsx = (SELECT mahangsx FROM hangsx WHERE tenhang = @tenhang)

    -- Xóa hãng hàng hóa
    DELETE FROM hangsx
    WHERE tenhang = @tenhang

    COMMIT

    PRINT N'Xóa hãng sản xuất thành công.'
END
go
go
EXEC XoaHangSX @tenhang = 'SamSung1'
go
-- cau 4
CREATE PROCEDURE NhapLieuNhanVien
    @manv INT,
    @tennv NVARCHAR(50),
    @gioitinh NVARCHAR(5),
    @diachi NVARCHAR(100),
    @sodt NVARCHAR(20),
    @email NVARCHAR(50),
    @phong NVARCHAR(50),
    @Flag BIT
AS
BEGIN
    IF @Flag = 0 -- Cập nhật nhân viên đã tồn tại
    BEGIN
        UPDATE nhanvien
        SET tennv = @tennv,
            gioitinh = @gioitinh,
            diachi = @diachi,
            sodt = @sodt,
            email = @email,
            phong = @phong
        WHERE manv = @manv
    END
    ELSE -- Thêm mới nhân viên
    BEGIN
        INSERT INTO nhanvien (manv, tennv, gioitinh, diachi, sodt, email, phong)
        VALUES (@manv, @tennv, @gioitinh, @diachi, @sodt, @email, @phong)
    END
END
EXEC NhapLieuNhanVien
@manv = 123,
@tennv = 'Nguyen Van A',
@gioitinh = 'Nam',
@diachi = 'Ha Noi',
@sodt = '0123456789',
@email = 'nguyenvana@gmail.com',
@phong = 'Kinh doanh',
@Flag = 1
-- cau 5
go
CREATE PROCEDURE ThemSuaNhap
    @sohdn varchar(20),
    @masp varchar(20),
    @manv varchar(20),
    @ngaynhap date,
    @soluongN int,
    @dongiaN decimal(18,2)
AS
BEGIN
    -- Kiểm tra sự tồn tại của masp và manv trong bảng Sanpham và Nhanvien
    IF NOT EXISTS (SELECT * FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Mã sản phẩm không tồn tại trong bảng Sanpham'
        RETURN
    END

    IF NOT EXISTS (SELECT * FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT N'Mã nhân viên không tồn tại trong bảng Nhanvien'
        RETURN
    END

    -- Kiểm tra sự tồn tại của sohdn trong bảng Nhap
    IF EXISTS (SELECT * FROM Nhap WHERE sohdn = @sohdn)
    BEGIN
-- Cập nhật bảng Nhap theo sohdn
        UPDATE Nhap
        SET masp = @masp,
            manv = @manv,
            ngaynhap = @ngaynhap,
            soluongN = @soluongN,
            dongiaN = @dongiaN
        WHERE sohdn = @sohdn
        PRINT N'Cập nhật dữ liệu cho bảng Nhap thành công'
    END
    ELSE
    BEGIN
        -- Thêm mới bảng Nhap
        INSERT INTO Nhap (sohdn, masp, manv, ngaynhap, soluongN, dongiaN)
        VALUES (@sohdn, @masp, @manv, @ngaynhap, @soluongN, @dongiaN)
        PRINT N'Thêm mới dữ liệu vào bảng Nhap thành công'
    END
END
go
go
EXEC ThemSuaNhap 'HD001', 'SP001', 'NV001', '2023-04-07', 10, 50000.00
go
-- cau 7
CREATE PROCEDURE XoaNhanVien
    @manv INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra xem manv có tồn tại trong bảng nhanvien hay không
    IF NOT EXISTS (SELECT * FROM nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Không tìm thấy nhân viên có mã ' + CAST(@manv AS VARCHAR(10))
        RETURN
    END

    -- Xóa các bản ghi trong bảng Nhap và Xuat mà nhân viên này tham gia
    DELETE FROM Nhap WHERE manv = @manv
    DELETE FROM Xuat WHERE manv = @manv
    -- Xóa bản ghi trong bảng nhanvien
    DELETE FROM nhanvien WHERE manv = @manv

    PRINT 'Đã xóa nhân viên có mã ' + CAST(@manv AS VARCHAR(10))
END

-- cau 6
go
CREATE PROCEDURE ThemSuaXuat
    @sohdx INT,
    @masp INT,
    @manv INT,
    @ngayxuat DATE,
    @soluongX INT
AS
BEGIN
    -- Kiểm tra sự tồn tại của sản phẩm và nhân viên
    IF NOT EXISTS (SELECT 1 FROM Sanpham WHERE masp = @masp)
    BEGIN
        PRINT 'Mã sản phẩm không tồn tại!'
        RETURN
    END
    
    IF NOT EXISTS (SELECT 1 FROM Nhanvien WHERE manv = @manv)
    BEGIN
        PRINT 'Mã nhân viên không tồn tại!'
        RETURN
    END
    
    -- Kiểm tra số lượng tồn kho
    DECLARE @soluongton INT
    SELECT @soluongton = soluong FROM Sanpham WHERE masp = @masp
    
    IF @soluongX > @soluongton
    BEGIN
        PRINT 'Số lượng xuất vượt quá số lượng tồn kho!'
        RETURN
    END
    
    -- Kiểm tra sự tồn tại của số hóa đơn xuất
    IF EXISTS (SELECT 1 FROM Xuat WHERE sohdx = @sohdx)
    BEGIN
        UPDATE Xuat
        SET masp = @masp,
            manv = @manv,
            ngayxuat = @ngayxuat,
            soluongX = @soluongX
        WHERE sohdx = @sohdx
    END
    ELSE
    BEGIN
        INSERT INTO Xuat(sohdx, masp, manv, ngayxuat, soluongX)
        VALUES(@sohdx, @masp, @manv, @ngayxuat, @soluongX)
    END
END

-- cau 8
go
CREATE PROCEDURE Xoasanpham(@masp int)
AS
BEGIN
  -- Kiểm tra masp có tồn tại trong bảng Sanpham hay không?
  IF NOT EXISTS(SELECT * FROM Sanpham WHERE masp = @masp)
  BEGIN
    PRINT 'Mã sản phẩm không tồn tại!'
    RETURN
  END
  
  -- Xóa các bản ghi trong bảng Nhap liên quan đến masp
  DELETE FROM Nhap WHERE masp = @masp
-- Xóa các bản ghi trong bảng Xuat liên quan đến masp
  DELETE FROM Xuat WHERE masp = @masp
  
  -- Xóa bản ghi trong bảng Sanpham
  DELETE FROM Sanpham WHERE masp = @masp
  
  PRINT 'Xóa sản phẩm thành công!'
END