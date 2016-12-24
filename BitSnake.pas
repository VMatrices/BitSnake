Program BitSnaker;
uses crt,dos;
// Ver 2.1 β
// By iBelieve 
// QQ 871674823
const
        max_high=40;
        max_wide=40;
        px :array[1..4] of -1..1=(0,0,-1,1);
        py :array[1..4] of -1..1=(-1,1,0,0);
        body:array[0..11] of string=('  ','─','│','┌','└','┐','┘','●','↑','↓','←','→');
type
        coordinate=record
                x :integer;
                y :integer;
        end;

var
        snake :array[1..1024] of coordinate;
        map :array[0..max_wide,0..max_wide] of boolean;
        map_print :array[1..max_wide,1..max_wide] of integer;
        i,j,p,tp,step,high,wide,apple_x,apple_y,snake_length :integer;
        t1,t2 :word;
        run,skip,flag :boolean;
        key:char;
        wide_s,high_s :string;

procedure printsnake();        //打印贪吃蛇
var i,j:longint;
begin
        gotoxy(11,5); write(snake[snake_length].x);
        gotoxy(19,5); write(snake[snake_length].y);
        gotoxy(11,6); write(apple_x);
        gotoxy(19,6); write(apple_y);
        for i:=1 to high do
                for j:=1 to wide do begin
                        gotoxy((j+1)*2-1,i+7);
                        write(body[map_print[j,i]]);
                end;
        gotoxy(8,high+9); write(step);
        gotoxy(20,high+9); write(snake_length-2);
end;


procedure setapple();        //随机放置食物
begin
        repeat
                apple_x:=random(wide)+1;
                apple_y:=random(high)+1;
        until map[apple_x,apple_y];
end;

procedure drawsnake();        //绘制贪吃蛇
var  i:integer;
       x,y:real;

begin
        fillchar(map_print,sizeof(map_print),0);
        for i:=2 to snake_length-1 do begin
                if snake[i-1].x=snake[i+1].x then begin
                                map_print[snake[i].x,snake[i].y]:=2
                        end else if snake[i-1].y=snake[i+1].y then begin
                                        map_print[snake[i].x,snake[i].y]:=1
                                end else begin
                                        x:=(snake[i-1].x+snake[i+1].x)/2;
                                        y:=(snake[i-1].y+snake[i+1].y)/2;
                                        if (snake[i].x<x) and (snake[i].y<y) then map_print[snake[i].x,snake[i].y]:=3;
                                        if (snake[i].x>x) and (snake[i].y<y) then map_print[snake[i].x,snake[i].y]:=5;
                                        if (snake[i].x<x) and (snake[i].y>y) then map_print[snake[i].x,snake[i].y]:=4;
                                        if (snake[i].x>x) and (snake[i].y>y) then map_print[snake[i].x,snake[i].y]:=6;
                                end;
        end;
        if snake[1].x=snake[2].x then
                map_print[snake[1].x,snake[1].y]:=2
                        else
                                map_print[snake[1].x,snake[1].y]:=1;
        if (snake[snake_length].x=snake[snake_length-1].x) and (snake[snake_length].y>snake[snake_length-1].y)  then map_print[snake[snake_length].x,snake[snake_length].y]:=9;
        if (snake[snake_length].x=snake[snake_length-1].x) and (snake[snake_length].y<snake[snake_length-1].y)  then map_print[snake[snake_length].x,snake[snake_length].y]:=8;
        if (snake[snake_length].x<snake[snake_length-1].x) and (snake[snake_length].y=snake[snake_length-1].y)  then map_print[snake[snake_length].x,snake[snake_length].y]:=10;
        if (snake[snake_length].x>snake[snake_length-1].x) and (snake[snake_length].y=snake[snake_length-1].y)  then map_print[snake[snake_length].x,snake[snake_length].y]:=11;
        if snake_length<wide*high then map_print[apple_x,apple_y]:=7;
end;

function move(direct:integer):boolean;        //负责贪吃蛇移动及判断
var i,x,y:integer;
begin
        x:=snake[snake_length].x+px[direct];
        y:=snake[snake_length].y+py[direct];
        if ((not map[x,y])and(not((x=snake[1].x)and(y=snake[1].y))))or(x<1)or(y<1)or(x>wide)or(y>high) then exit(false); //判断是否越界和吃到自己
        map[x,y]:=false;
        if  (x=apple_x)and(y=apple_y) then begin
                inc(snake_length);
                if snake_length<wide*high then setapple();
        end else begin
                map[snake[1].x,snake[1].y]:=true;
                for i:=1 to snake_length-1 do snake[i]:=snake[i+1];
        end;
        snake[snake_length].x:=x;
        snake[snake_length].y:=y;
        drawsnake();
        exit(true);
end;

procedure initialize();        //初始化
begin
        assign(output,'CON');
        rewrite(output);
        str((wide+2)*2+1,wide_s);
        str(high+13,high_s);
        exec('cmd','/c mode con cols='+wide_s+' lines='+high_s);
        randomize;
        fillchar(map,sizeof(map),true);
        fillchar(map_print,sizeof(map_print),0);
        snake[1].x:=wide div 2;
        snake[1].y:=high div 2;
        snake[2].x:=snake[1].x;
        snake[2].y:=snake[1].y-1;
        map[snake[1].x,snake[1].y]:=false;
        map[snake[2].x,snake[2].y]:=false;
        snake_length:=2;
        run:=true;
        flag:=true;
        step:=0;
        p:=1;
        cursoroff;
	clrscr;
        setapple();
        drawsnake();
        write('┌');        //打印地图
        for i:=1 to wide do write('─');
        writeln('┐');
        write('│BitSnake V2.1 Beta');
	for i:=1 to wide-9 do write('  ');
	writeln('│');
        write('└');
        for i:=1 to wide do write('─');
        writeln('┘');;
        writeln('  Map   High:',high,' Wide:',wide);
        writeln('  Head  X:      Y:');
        writeln('  Food  X:      Y:');
        write('┏');
        for i:=1 to wide do write('┉');
        writeln('┓');
        for i:=1 to high do begin
                write('┋');
                for j:=1 to wide do write(body[0]);
                write('┋');
                writeln;
        end;
        write('┗');
        for i:=1 to wide do write('┉');
        writeln('┛');
        writeln('  Step:      Score:');
        writeln('  (W S A D / Pause Space)');
        for i:=1 to wide+2 do write('─');
	writeln;
	for i:=1 to wide-10 do write('  ');
	write('─iBelieve  QQ:871674823');
        printsnake();
end;

begin        //主程序
        exec('cmd.exe','/c title BitSnake');
        writeln('Please enter the map size(high width):');
	writeln('[6<high<16, 14<wide<32]');
	gotoxy(40,1);
        readln(high,wide);
        if (high>max_high)or(wide>max_wide)or(high<6)or(wide<9) then exit;
        initialize();
        while run do begin
                skip:=false;
                gettime(t1,t1,t1,t1);
                while not skip do begin
                        if keypressed then begin        //读取键值
                                if keypressed  then begin
                                        key:=readkey;
                                        skip:=true;
                                        tp:=p;
                                        case key of
                                                'w':p:=1;
                                                's':p:=2;
                                                'a':p:=3;
                                                'd':p:=4;
                                                ' ':begin        //游戏暂停
                                                        gotoxy(3,8);
                                                        write('Pause...');
                                                        while not keypressed do;
                                                    end;
                                                '0':flag:=not flag;        //开启或关闭自动前进
                                        end;
                                        if (abs(p-tp)=1)and(p+tp<>5) then p:=tp;
                                end;
                        end else begin
                                gettime(t2,t2,t2,t2);
                                if (abs(t1-t2)>50)and(flag) then skip:=true;
                        end;
                end;
                inc(step);
                if move(p) then begin
                        printsnake();
                        if  snake_length=high*wide then begin
                                gotoxy(3,8);
                                write('You Win!');
                                run:=false;
                        end;
                end else begin
                        printsnake();
                        gotoxy(3,8);
                        write('Game Over!');
                        run:=false;
                end;
        end;
        while true do;
end.
