--赤座あかり
function c1000.initial_effect(c)

	-- battle indes
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1) -- 1ターンに1度しか効果を使用できないようにする
	e1:SetValue(c1000.valcon)
	c:RegisterEffect(e1)

	-- draw
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1000, 0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1000.condition)
	e2:SetTarget(c1000.target)
	e2:SetOperation(c1000.operation)
	c:RegisterEffect(e2)

end

-- 戦闘の場合は破壊されない
function c1000.valcon(e, re, r, rp)
	return bit.band(r, REASON_BATTLE) ~= 0
end

-- <どういう条件時に発動できるのか>
function c1000.condition(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	-- 相手の効果よってフィールドから墓地に送られたとき
	return re and rp ~= tp and c:IsReason(REASON_DESTROY) and c:GetPreviousControler() == tp and c:IsPreviousLocation(LOCATION_ONFIELD)
end

-- <誰がなにを対象に発動するのか>
function c1000.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

-- <効果の内容>
function c1000.operation(e, tp, eg, ep, ev, re, r, rp)
	local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
	Duel.Draw(p, d, REASON_EFFECT) -- 自分はデッキから1枚ドローする
end
