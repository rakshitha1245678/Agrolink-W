const jwt = require('jsonwebtoken');
const db = require('../config/db');
exports.authenticate = async (req,res,next) => { try { const token=req.cookies.token || (req.headers.authorization||'').replace(/^Bearer\s+/,''); if(!token) return res.status(401).json({message:'Authentication required'}); const data=jwt.verify(token,process.env.JWT_SECRET); const {rows}=await db.query('SELECT id,name,email,role,active FROM users WHERE id=$1',[data.id]); if(!rows[0]||!rows[0].active) return res.status(401).json({message:'Account unavailable'}); req.user=rows[0]; next(); } catch { res.status(401).json({message:'Invalid or expired token'}); } };
exports.authorize = (...roles) => (req,res,next) => roles.includes(req.user.role) ? next() : res.status(403).json({message:'Access denied'});
